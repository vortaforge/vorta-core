# macro $(slot) $(item) $(id) $(type) $(menu) $(ntext)
$item replace entity @e[type=#guikit:container,tag=guikit.me,limit=1] container.$(slot) with $(item)[custom_name={"text":"$(ntext)","italic":false},custom_data={guikit:{widget:1,type:"$(type)",id:"$(id)",pack:"guikit",menu:"$(menu)"}},max_stack_size=1]
