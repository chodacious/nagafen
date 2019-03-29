function Get-PvpStats {

    param(
        $worldId = '609',
        $serviceId
    )
        
        $characterData = [xml](Invoke-WebRequest -Uri "http://census.daybreakgames.com/s:$serviceId/xml/get/eq2/character/?locationdata.worldid=$worldId&c:show=name,pvp&c:limit=2000" -TimeoutSec 360)
        $naggyChars = $characterData.character_list.character.name.first_lower

        $Output = @()

        foreach ($char in $naggyChars)
            {
                $charInfo = $characterData.character_list.character | where {$_.name.first_lower -eq $char}

                $OutTemp = New-Object PSObject
                $OutTemp | Add-Member -MemberType NoteProperty -Name 'charName' -Value ""
                $OutTemp | Add-Member -MemberType NoteProperty -Name 'kdr' -Value ""
                $OutTemp | Add-Member -MemberType NoteProperty -Name 'kills' -Value ""
                $OutTemp | Add-Member -MemberType NoteProperty -Name 'deaths' -Value ""
                $OutTemp | Add-Member -MemberType NoteProperty -Name 'fameValue' -Value ""
                $OutTemp | Add-Member -MemberType NoteProperty -Name 'pvpTitle' -Value ""

                $charName = $charInfo.name.first
                $fameValue = $charInfo.pvp.title_rank
                $kdr = $charInfo.pvp.kvd
                $kills = $charInfo.pvp.total_kills
                $deaths = $charInfo.pvp.deaths
        
                $OutTemp.charName = $charName
                $OutTemp.kdr = $kdr
                $OutTemp.kills = $kills
                $OutTemp.deaths = $deaths

                $OutTemp.fameValue = $fameValue = ([int]$fameValue - 1000)

                switch ($fameValue)
                    {
                        {($_ -ge 0)    -and  ($_ -le 99)}    {$pvpTitle = 'Unranked'}
                        {($_ -ge 100)  -and  ($_ -le 199)}   {$pvpTitle = 'Hunter'}
                        {($_ -ge 200)  -and  ($_ -le 299)}   {$pvpTitle = 'Slayer'}
                        {($_ -ge 300)  -and  ($_ -le 399)}   {$pvpTitle = 'Destroyer'}
                        {($_ -ge 400)  -and  ($_ -le 499)}   {$pvpTitle = 'Champion'}
                        {($_ -ge 500)  -and  ($_ -le 599)}   {$pvpTitle = 'Dreadnaught'}
                        {($_ -ge 600)  -and  ($_ -le 699)}   {$pvpTitle = 'General'}
                        {($_ -ge 700)  -and  ($_ -le 799)}   {$pvpTitle = 'Master'}
                        {($_ -ge 800)  -and  ($_ -le 999)}   {$pvpTitle = 'Overseer'}
                        {($_ -ge 1000) -and ($_ -le 2999)}   {$pvpTitle = 'Overlord'}
                        {($_ -ge 3000)}                      {$pvpTitle = 'Warlord'}
                    }
                
                $OutTemp.pvpTitle = $pvpTitle
        
                $Output += $OutTemp

            }

    $Output

}

#Example - it'll default to Nagafen (world ID 609)
#Get-PvpStats -serviceId 'chodacious'
