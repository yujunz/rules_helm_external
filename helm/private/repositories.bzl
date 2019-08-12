load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@com_github_yujunz_rules_helm_external//helm/private:skylib/lib/versions.bzl", "versions")

MINIMUM_BAZEL_VERSION = "0.27"

def helm_rules_dependencies():
    """Declares workspaces the Helm rules depend on. Workspaces that use
    rules_helm should call this.
    """
    if getattr(native, "bazel_version", None):
        versions.check(MINIMUM_BAZEL_VERSION, bazel_version = native.bazel_version)

    _maybe(
        git_repository,
        name = "bazel_skylib",
        remote = "https://github.com/bazelbuild/bazel-skylib",
        # 0.8.0, latest as of 2019-07-08
        commit = "3721d32c14d3639ff94320c780a60a6e658fb033",
        shallow_since = "1553102012 +0100",
    )

def _maybe(repo_rule, name, **kwargs):
    if name not in native.existing_rules():
        repo_rule(name = name, **kwargs)
