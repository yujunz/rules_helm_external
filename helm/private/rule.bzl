def helm_rule(implementation, attrs = None, toolchains = None, **kwargs):
    attrs = attrs if attrs else {}
    toolchains = toolchains if toolchains else []

    attrs["_helm_context_data"] = attr.label(default = "com_github_yujunz_rules_helm//:helm_context_data")
    toolchains = toolchains + ["com_github_yujunz_rules_helm//helm:toolchain"]

    return rule(
        implementation = implementation,
        attrs = attrs,
        toolchains = toolchains,
        **kwargs
    )
