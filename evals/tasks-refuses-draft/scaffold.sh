#!/usr/bin/env bash
set -euo pipefail
d="$(dirname "${BASH_SOURCE[0]}")/../_fixtures"; source "$d/go-pricing.sh"; source "$d/coupons-spec.sh"; coupons_spec draft
