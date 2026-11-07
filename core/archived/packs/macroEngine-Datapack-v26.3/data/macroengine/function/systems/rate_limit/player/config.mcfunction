# macroengine:systems/rate_limit/player/config — Register per-player rate limit rule [MACRO]
#
# Creates one template rule. The player bucket key is "player:<key>:<player>".
# This function registers the TEMPLATE rule used for ALL players under this key.
# Individual player buckets are auto-created on first check.
#
# Usage:
# function macroengine:systems/rate_limit/player/config {key:"shop",limit:3,window:600}
#
# This allows: $function macroengine:systems/rate_limit/player/check {key:"shop",player:"$(player)"}
#
# Note: each player gets their own independent sliding window bucket.
# To register a SHARED (global) rule use macroengine:systems/rate_limit/config directly.

# Store template rule — concrete player buckets inherit limit+window on first hit
execute if data storage macroengine:engine modules{rate_limit:0b} run return 0
$data modify storage macroengine:engine rate_limit.player_templates.$(key) set value {limit:$(limit),window:$(window)}
