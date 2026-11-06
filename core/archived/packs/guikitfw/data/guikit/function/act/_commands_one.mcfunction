# macro $(cmd)
# Off by default: an operator enables stored commands with guikit:cfg dynamic_cmd.
execute unless data storage guikit:cfg {dynamic_cmd:1b} run return 0
$execute as @s at @s run $(cmd)
