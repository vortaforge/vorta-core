# Drop already consumed item entity; treat as shift click on matching id if present in actions
# Full port uses item NBT; here re-scan inv is empty — use left empty slots next tick instead
scoreboard players set @s guikit.click 0
