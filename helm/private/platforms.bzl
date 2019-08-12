BAZEL_HELM_OS_CONSTRAINTS = {
    "darwin": "@bazel_tools//platforms:osx",
    "linux": "@bazel_tools//platforms:linux",
}

BAZEL_HELM_ARCH_CONSTRAINTS = {
    "amd64": "@bazel_tools//platforms:x86_64",
}

HELM_OS_ARCH = (
    ("darwin", "amd64"),
    ("linux", "amd64"),
)

def _generate_constraints(names, bazel_constraints):
    return {
        name: bazel_constraints.get(name, "@com_github_yujunz_rules_helm_external//helm/toolchain:" + name)
        for name in names
    }

HELM_OS_CONSTRAINTS = _generate_constraints([p[0] for p in HELM_OS_ARCH], BAZEL_HELM_OS_CONSTRAINTS)
HELM_ARCH_CONSTRAINTS = _generate_constraints([p[1] for p in HELM_OS_ARCH], BAZEL_HELM_ARCH_CONSTRAINTS)

def _generate_platforms():
    platforms = []
    for os, arch in HELM_OS_ARCH:
        constraints = [
            HELM_OS_CONSTRAINTS[os],
            HELM_ARCH_CONSTRAINTS[arch],
        ]
        platforms.append(struct(
            name = os + "_" + arch,
            os = os,
            arch = arch,
            constraints = constraints,
        ))
    return platforms

PLATFORMS = _generate_platforms()

def generate_toolchain_names():
    # keep in sync with declare_toolchains
    return ["helm_" + p.name for p in PLATFORMS]
