# macroengine:core/queue/size
# Writes the current work_queue item count to macroengine:output queue.size.
# No macro input required.
#
# Output (macroengine:output queue):
#   size — int  number of pending items
#
# Usage:
#   function macroengine:core/queue/size
#   data get storage macroengine:output queue.size

execute store result storage macroengine:output queue.size int 1 run data get storage macroengine:engine work_queue