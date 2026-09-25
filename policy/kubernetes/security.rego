package main

import rego.v1

# ============================================================
# Kubernetes Security and Compliance Policy
#
# Applies to:
# - Deployments
# - StatefulSets
#
# Controls:
# 1. Prevent privilege escalation
# 2. Require non-root execution
# 3. Require explicit/versioned container images
# 4. Require baseline resource requests and memory limits
# ============================================================

# ------------------------------------------------------------
# Policy 1: Prevent privilege escalation
#
# Every container must explicitly disable privilege escalation.
# ------------------------------------------------------------

deny contains msg if {
	input.kind in {"Deployment", "StatefulSet"}

	some container in input.spec.template.spec.containers

	not container.securityContext.allowPrivilegeEscalation == false

	msg := sprintf(
		"%s container %q must set securityContext.allowPrivilegeEscalation to false",
		[input.kind, container.name],
	)
}

# ------------------------------------------------------------
# Policy 2: Require non-root execution
#
# runAsNonRoot may be configured at either:
# - Pod securityContext level, or
# - Container securityContext level
# ------------------------------------------------------------

deny contains msg if {
	input.kind in {"Deployment", "StatefulSet"}

	some container in input.spec.template.spec.containers

	not run_as_non_root(input, container)

	msg := sprintf(
		"%s container %q must run as non-root",
		[input.kind, container.name],
	)
}

# ------------------------------------------------------------
# Policy 3: Require explicit container image versions
#
# Reject:
# - Images using the mutable :latest tag
# - Images without an explicit tag or digest
# ------------------------------------------------------------

deny contains msg if {
	input.kind in {"Deployment", "StatefulSet"}

	some container in input.spec.template.spec.containers

	endswith(container.image, ":latest")

	msg := sprintf(
		"%s container %q must not use the mutable :latest image tag",
		[input.kind, container.name],
	)
}

deny contains msg if {
	input.kind in {"Deployment", "StatefulSet"}

	some container in input.spec.template.spec.containers

	not contains(container.image, ":")
	not contains(container.image, "@sha256:")

	msg := sprintf(
		"%s container %q must use an explicit image tag or digest",
		[input.kind, container.name],
	)
}

# ------------------------------------------------------------
# Policy 4: Require baseline container resource controls
#
# Required:
# - CPU request
# - Memory request
# - Memory limit
#
# CPU limits are intentionally optional to avoid unnecessary
# CPU throttling for application and monitoring workloads.
# ------------------------------------------------------------

deny contains msg if {
	input.kind in {"Deployment", "StatefulSet"}

	some container in input.spec.template.spec.containers

	not container.resources.requests.cpu

	msg := sprintf(
		"%s container %q must define a CPU request",
		[input.kind, container.name],
	)
}

deny contains msg if {
	input.kind in {"Deployment", "StatefulSet"}

	some container in input.spec.template.spec.containers

	not container.resources.requests.memory

	msg := sprintf(
		"%s container %q must define a memory request",
		[input.kind, container.name],
	)
}

deny contains msg if {
	input.kind in {"Deployment", "StatefulSet"}

	some container in input.spec.template.spec.containers

	not container.resources.limits.memory

	msg := sprintf(
		"%s container %q must define a memory limit",
		[input.kind, container.name],
	)
}

# ============================================================
# Helper Rules
# ============================================================

# Return true when non-root execution is configured at
# the Pod securityContext level.
run_as_non_root(workload, container) if {
	workload.spec.template.spec.securityContext.runAsNonRoot == true
}

# Return true when non-root execution is configured at
# the individual container securityContext level.
run_as_non_root(workload, container) if {
	container.securityContext.runAsNonRoot == true
}
