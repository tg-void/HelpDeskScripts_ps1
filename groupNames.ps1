#The variables $names and $headers (line 21) can be changed accordingly as needed. To add a group, add the name to the correct alphabeltical location in $names.
    #$headers should be changed accordingly with $names to have the correct number. For example, if you have 55 names the value of $headers should be changed to 
    #"1-10,11-20,21-30,31-40,41-50,51-55" to maintain the correct csv format.

$names = @('Banerjee','Barondeau','Batteas','Begley','Bergbreiter','Bluemel','Burgess','Clearfield','Darensburg','Dunbar','Fang','FYP','Gabbai','Gladysz','Groups',
'Hilty','Laane','Laganowsky','Lindahl','Liu','MassSpec','MS-ILSB','Nippe','NMR','North','Ozerov','Powers','Raushel','Rosynek','Russel','Schweikert','Sczepanski','Sheldon',
'Son','Watanabe','Wooley','Xray','Yan','Zhou','Zingaro')
[System.Collections.ArrayList]$gNames = @('','','','','','','','','','') #10 names per column

$i = 0
foreach ($name in $names){ #sorting names into array of strings/csv format
    $i++
    for ($j = 0; $j -lt 10; $j++){
        if ($i % 10 -eq $j) {$gNames[$j] += "$($i)." + $name + ','}
    }
}

$last = $gNames[0] #readjusting the array to fix so names listed in correct order
$gNames.RemoveAt(0)
[void]$gNames.add($last)

[String]$headers = "1-10,11-20,21-30,31-40" #adding headers to array
$gNames.insert(0, $headers)

convertfrom-csv -inputobject $gNames | format-table -autosize #outputs to screen