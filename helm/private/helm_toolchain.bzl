load(
    "@com_github_yujunz_rules_helm//helm/private:providers.bzl",
    "HelmCLI",
)
load(
    "@com_github_yujunz_rules_helm//helm/private:platforms.bzl",
    "PLATFORMS",
)
load(
    "@com_github_yujunz_rules_helm//helm/private:actions/package.bzl",
    "emit_package",
)

"""
Toolchain rules used by helm
"""

def _helm_toolchain_impl(ctx):
    cli = ctx.attr.cli[HelmCLI]
    cross_compile = ctx.attr.os != cli.os or ctx.attr.arch != cli.arch
    return [platform_common.ToolchainInfo(
        # Public fields
        name = ctx.label.name,
        cross_compile = cross_compile,
        default_os = ctx.attr.os,
        default_arch = ctx.attr.arch,
        actions = struct(
            package = emit_package,
        ),
        cli = cli,
    )]

helm_toolchain = rule(
    _helm_toolchain_impl,
    attrs = {
        # Minimum requirements to specify a toolchain
        "os": attr.string(
            mandatory = True,
            doc = "Default target OS",
        ),
        "arch": attr.string(
            mandatory = True,
            doc = "Default target architecture",
        ),
        "cli": attr.label(
            mandatory = True,
            providers = [HelmCLI],
            doc = "The cli this toolchain is based on",
        ),
    },
    doc = "Defines a Helm toolchain on some cli",
    provides = [platform_common.ToolchainInfo],
)

def declare_toolchains(host, cli):
    # keep in sync with generate_toolchain_names
    host_os, _, host_arch = host.partition("_")
    for p in PLATFORMS:
        toolchain_name = "helm_" + p.name
        impl_name = toolchain_name + "-impl"
        constraints = p.constraints

        helm_toolchain(
            name = impl_name,
            os = p.os,
            arch = p.arch,
            cli = cli,
            tags = ["manual"],
            visibility = ["//visibility:public"],
        )
        native.toolchain(
            name = toolchain_name,
            toolchain_type = "@com_github_yujunz_rules_helm//helm:toolchain",
            exec_compatible_with = [
                "@com_github_yujunz_rules_helm//helm/toolchain:" + host_os,
                "@com_github_yujunz_rules_helm//helm/toolchain:" + host_arch,
            ],
            target_compatible_with = constraints,
            toolchain = ":" + impl_name,
        )
