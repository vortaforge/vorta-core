# macro $(slot) $(filler) $(x) $(y) $(z)
$execute unless items block $(x) $(y) $(z) container.$(slot) * run item replace block $(x) $(y) $(z) container.$(slot) with $(filler)[custom_data={guikit:{widget:1,type:"separator",id:"fill_$(slot)",pack:"guikit"}},max_stack_size=1]
