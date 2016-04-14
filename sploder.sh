#!/bin/bash
# Size exploder

ranges_array=(s m l)
last_element_index=$((${#ranges_array[@]}-1))
begin_range="${ranges_array[0]}"
end_range="${ranges_array[$last_element_index]}"
echo "$begin_range $end_range"