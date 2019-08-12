load(
    "@com_github_yujunz_rules_helm_external//helm/private:platforms.bzl",
    "HELM_ARCH_CONSTRAINTS",
    "HELM_OS_CONSTRAINTS",
    "PLATFORMS",
)

def declare_constraints():
    """Generates constraint_values and platform targets for valid platforms.

    Each constraint_value corresponds to a valid os or goarch.
    The os and goarch values belong to the constraint_settings
    @bazel_tools//platforms:os and @bazel_tools//platforms:cpu, respectively.
    To avoid redundancy, if there is an equivalent value in @bazel_tools,
    we define an alias here instead of another constraint_value.

    Each platform defined here selects a os and goarch constraint value.
    These platforms may be used with --platforms for cross-compilation,
    though users may create their own platforms (and
    @bazel_tools//platforms:default_platform will be used most of the time).
    """
    for os, constraint in HELM_OS_CONSTRAINTS.items():
        if constraint.startswith("@com_github_yujunz_rules_helm_external//helm/toolchain:"):
            native.constraint_value(
                name = os,
                constraint_setting = "@bazel_tools//platforms:os",
            )
        else:
            native.alias(
                name = os,
                actual = constraint,
            )

    for arch, constraint in HELM_ARCH_CONSTRAINTS.items():
        if constraint.startswith("@com_github_yujunz_rules_helm_external//helm/toolchain:"):
            native.constraint_value(
                name = arch,
                constraint_setting = "@bazel_tools//platforms:cpu",
            )
        else:
            native.alias(
                name = arch,
                actual = constraint,
            )

    for p in PLATFORMS:
        native.platform(
            name = p.name,
            constraint_values = p.constraints,
        )
