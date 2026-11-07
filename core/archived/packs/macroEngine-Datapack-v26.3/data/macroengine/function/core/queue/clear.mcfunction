# macroengine:core/queue/clear
# Discards all pending work_queue items immediately.
# No macro input required.
#
# Usage:
#   function macroengine:core/queue/clear

data modify storage macroengine:engine work_queue set value []