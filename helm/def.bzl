def _helm_chart_impl(ctx):
    return []

def helm_chart():
    return rule(
        implementation = _helm_chart_impl,
        attrs = {},
        toolchains = ["@com_github_yujunz_rules_helm//helm:toolchain"],
        **kwargs
    )
