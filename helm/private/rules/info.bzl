load(
    "@com_github_yujunz_rules_helm//helm/private:context.bzl",
    "helm_context",
)
load(
    "@com_github_yujunz_rules_helm//helm/private:rules/rule.bzl",
    "helm_rule",
)

def _helm_info_impl(ctx):
    helm = helm_context(ctx)
    report = helm.declare_file(helm, "helm_info_report")
    args = helm.builder_args(helm)
    args.add("-out", report)
    helm.actions.run(
        inputs = helm.sdk_files,
        outputs = [report],
        mnemonic = "GoInfo",
        executable = ctx.executable._helm_info,
        arguments = [args],
    )
    return [DefaultInfo(
        files = depset([report]),
        runfiles = ctx.runfiles([report]),
    )]

_helm_info = helm_rule(
    _helm_info_impl,
    attrs = {
        "_helm_info": attr.label(
            executable = True,
            cfg = "host",
            default = "@com_github_yujunz_rules_helm//helm/tools/builders:info",
        ),
    },
)

def helm_info():
    _helm_info(
        name = "helm_info",
        visibility = ["//visibility:public"],
    )
