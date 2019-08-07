load(
    "@com_github_yujunz_rules_helm//helm/private:providers.bzl",
    "HelmCLI",
)

def _helm_cli_impl(ctx):
    return [HelmCLI(
        os = ctx.attr.os,
        arch = ctx.attr.arch,
        home_file = ctx.file.home_file,
        helm = ctx.executable.helm,
    )]

helm_cli = rule(
    _helm_cli_impl,
    attrs = {
        "os": attr.string(
            mandatory = True,
            doc = "The host OS the cli was built for",
        ),
        "arch": attr.string(
            mandatory = True,
            doc = "The host architecture the cli was build for",
        ),
        "home_file": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = ("A file in the helm home directory. Used to determine HELM_HOME"),
        ),
        "helm": attr.label(
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "host",
            doc = "The helm cli",
        ),
    },
    doc = "Collects infroamtion about a Helm cli. The cli must have a normal HELM_HOME",
    provides = [HelmCLI],
)
