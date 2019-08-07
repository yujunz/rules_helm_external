HelmChart = provider()
"""
A represenatation of the inputs to a helm chart.
This is a configuration independent provider.
You must call resolve with a mode to produce a HelmSource.
"""

HelmSource = provider()
"""
The filtered inputs and dependencies needed to build a HelmPackage
This is a configuration specific provider.
It has no transitive information.
"""

HelmPackageData = provider()
"""
This packaged form of a chart used in transitive dependencies.
This is a configuration specific provider.
"""

HelmPackage = provider()
"""
The packaged form of a HelmChart, with all dependencies embedded.
This is a configuration specific provider.
"""

HelmAspectProviders = provider()

HelmCLI = provider(
    doc = "Contains information about the Helm CLI used in the toolchain",
    fields = {
        "os": "The host OS the cli was built for.",
        "arch": "The host architecture the binray was built for.",
        "home_file": "A file in the cli root directory",
        "helm": "The helm binray",
    },
)

def get_source(dep):
    if type(dep) == "struct":
        return dep
    if HelmAspectProviders in dep:
        return dep[HelmAspectProviders].source
    return dep[HelmSource]
