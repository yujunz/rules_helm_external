load(
    "@com_github_yujunz_rules_helm_external//helm/private:cli_list.bzl",
    "BINARY_REPOSITORIES",
    "DEFAULT_VERSION",
    "MIN_SUPPORTED_VERSION",
)
load(
    "@com_github_yujunz_rules_helm_external//helm/private:platforms.bzl",
    "generate_toolchain_names",
)
load(
    "@com_github_yujunz_rules_helm_external//helm/private:skylib/lib/versions.bzl",
    "versions",
)

def _detect_host_platform(ctx):
    if ctx.os.name == "linux":
        host = "linux_amd64"
    elif ctx.os.name == "mac os x":
        host = "darwin_amd64"
    else:
        fail("Unsupported operating system: " + ctx.os.name)

    return host

def _register_toolchains(repo):
    labels = [
        "@{}//:{}".format(repo, name)
        for name in generate_toolchain_names()
    ]
    native.register_toolchains(*labels)

def _local_cli(ctx, path):
    for entry in ["cache", "plugins", "repository", "starters"]:
        ctx.symlink(path + "/" + entry, entry)

def _cli_build_file(ctx, platform):
    ctx.file("HOME")
    os, _, arch = platform.partition("_")
    ctx.template(
        "BUILD.bazel",
        Label("@com_github_yujunz_rules_helm_external//helm/private:BUILD.cli.bazel"),
        executable = False,
        substitutions = {
            "{os}": os,
            "{arch}": arch,
        },
    )

def helm_register_toolchains(helm_version = None):
    cli_kinds = ("_helm_download_cli")
    existing_rules = native.existing_rules()
    cli_rules = [r for r in existing_rules.values() if r["kind"] in cli_kinds]
    if len(cli_rules) == 0 and "helm_cli" in existing_rules:
        # may be local_repository in bazel_tests.
        cli_rules.append(existing_rules["helm_cli"])

    if helm_version and len(cli_rules) > 0:
        fail("helm_version set after helm cli rule declared ({})".format(", ".join([r["name"] for r in cli_rules])))
    if len(cli_rules) == 0:
        if not helm_version:
            helm_version = DEFAULT_VERSION
        if not versions.is_at_least(MIN_SUPPORTED_VERSION, helm_version):
            fail("ERROR: helm versions before {} not supported".format(MIN_SUPPORTED_VERSION))
        helm_download_cli(
            name = "helm_cli",
            version = helm_version,
        )

def _helm_download_cli_impl(ctx):
    if ctx.attr.version:
        if ctx.attr.binaries:
            fail("version and binaries must not both be set")
        if ctx.attr.version not in BINARY_REPOSITORIES:
            fail("unknown Helm version: {}".format(ctx.attr.version))
        binaries = BINARY_REPOSITORIES[ctx.attr.version]
    elif ctx.attr.binaries:
        binaries = ctx.attr.binaries
    else:
        binaries = BINARY_REPOSITORIES[DEFAULT_VERSION]
    if not ctx.attr.os and not ctx.attr.arch:
        platform = _detect_host_platform(ctx)
    else:
        if not ctx.attr.os:
            fail("arch set but os not set")
        if not ctx.attr.arch:
            fail("os set but arch not set")
        platform = ctx.attr.os + "_" + ctx.attr.arch
    if platform not in binaries:
        fail("unsupported platform {}".format(platform))
    filename, sha256 = binaries[platform]
    _cli_build_file(ctx, platform)
    _remote_cli(ctx, [url.format(filename) for url in ctx.attr.urls], ctx.attr.strip_prefix, sha256)

_helm_download_cli = repository_rule(
    _helm_download_cli_impl,
    attrs = {
        "os": attr.string(),
        "arch": attr.string(),
        "binaries": attr.string_list_dict(),
        "urls": attr.string_list(default = ["https://get.helm.sh/{}"]),
        "version": attr.string(),
        "strip_prefix": attr.string(),
    },
)

def helm_download_cli(name, **kwargs):
    _helm_download_cli(name = name, **kwargs)
    _register_toolchains(name)

def _helm_local_cli_impl(ctx):
    helmhome = ctx.attr.path
    platform = _detect_host_platform(ctx)
    _cli_build_file(ctx, platform)
    _local_cli(ctx, helmhome)

_helm_local_cli = repository_rule(
    _helm_local_cli_impl,
    attrs = {
        "path": attr.string(),
    },
)

def helm_local_cli(name, **kwargs):
    _helm_local_cli(name = name, **kwargs)
    _register_toolchains(name)

def _remote_cli(ctx, urls, strip_prefix, sha256):
    # TODO(bazelbuild/bazel#7055): download_and_extract fails to extract
    # archives containing files with non-ASCII names.
    if len(urls) == 0:
        fail("no urls specified")
    if urls[0].endswith(".tar.gz"):
        if not strip_prefix:
            strip_prefix = ctx.attr.os + "-" + ctx.attr.arch
        ctx.download(
            url = urls,
            sha256 = sha256,
            output = "helm_cli.tar.gz",
        )
        res = ctx.execute(["tar", "-xf", "helm_cli.tar.gz", "--strip-components=1"])
        if res.return_code:
            fail("error extracting Helm cli:\n" + res.stdout + res.stderr)
        ctx.execute(["rm", "helm_cli.tar.gz"])
    else:
        ctx.download_and_extract(
            url = urls,
            stripPrefix = strip_prefix,
            sha256 = sha256,
        )
