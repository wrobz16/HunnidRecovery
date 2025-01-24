_setPlayerData( statValue, statString, player )
{
    if( !self areYouSure() )
        return;

    player SetDStat( "playerstatslist", statString, "StatValue", statValue );
    player setRank( player rank::getRankForXp( player rank::getRankXP() ), player GetDStat("playerstatslist", "PLEVEL", "StatValue") );
    wait .1;
    UploadStats(player);
}

setMaxLevel(player)
{
    player SetDStat ( "playerstatslist", "plevel", "StatValue", 11 );
    player setRank( player rank::getRankForXp( player rank::getRankXP() ), player GetDStat("playerstatslist", "PLEVEL", "StatValue") );
    wait .1;
    UploadStats(player);
    wait .1;
    player addPlayerXP( 1000, player );
}

addPlayerXP( value, player )
{
    if( !self areYouSure() )
        return;
    if( value > 35 )
    {
        xpTable = int(tableLookup( "gamedata/tables/zm/zm_paragonranktable.csv", 0, value - 36, ((value == 100) ? 7 : 2) ));
        old = int(player GetDStat("playerstatslist", "paragon_rankxp", "statValue"));
    }
    else 
    {
        xpTable = int(tableLookup( "gamedata/tables/zm/zm_ranktable.csv", 0, value - 1, ((value == 35) ? 7 : 2) ));
        old = int(player GetDStat("playerstatslist", "rankxp", "statValue"));
    }

    player AddRankXPValue("win", xpTable - old);
    wait .1;
    UploadStats(player);
    self refreshMenuToggles();
}

getCurrentRank(player)
{
    if(player.pers["plevel"] > 10 && player GetDStat("playerstatslist", "paragon_rank", "StatValue") >= 1)
        return player GetDStat("playerstatslist", "paragon_rank", "StatValue") + 36;
    return player GetDStat("playerstatslist", "rank", "StatValue") + 1;    
}

do_all_challenges(player)
{
    if( !self areYouSure() )
        return;
    self thread progressbar( 0, 100, 1, .125 ); 

    for(value=512;value<642;value++)
    {
        stat         = spawnStruct();
        stat.value   = int( tableLookup( "gamedata/stats/zm/statsmilestones3.csv", 0, value, 2 ) );
        stat.type    = tableLookup( "gamedata/stats/zm/statsmilestones3.csv", 0, value, 3 );
        stat.name    = tableLookup( "gamedata/stats/zm/statsmilestones3.csv", 0, value, 4 );
        stat.split   = tableLookup( "gamedata/stats/zm/statsmilestones3.csv", 0, value, 13 );

        switch( stat.type )
        {
            case "global":
                player setDStat("playerstatslist", stat.name, "statValue", stat.value);
                player setDStat("playerstatslist", stat.name, "challengevalue", stat.value);
            break;

            case "attachment":
                foreach( attachment in strTok(stat.split, " ") )
                {
                    player SetDStat("attachments", attachment, "stats", stat.name, "statValue", stat.value);
                    player SetDStat("attachments", attachment, "stats", stat.name, "challengeValue", stat.value);
                    for(i = 1; i < 8; i++)
                    {
                        player SetDStat("attachments", attachment, "stats", "challenge" + i, "statValue", stat.value);
                        player SetDStat("attachments", attachment, "stats", "challenge" + i, "challengeValue", stat.value);
                    }
                }
            break;

            default:
                foreach( weapon in strTok(stat.split, " ") )         
                    player addWeaponStat( GetWeapon( weapon ), stat.name, stat.value ); 
            break;
        }
        wait .1;
    }
    player waittill("progress_done");
    player max_weapon_level( true );
    player.unlock_all = true;
    player refreshMenuToggles();
    UploadStats(player);
}

giveLiquid( value, player )
{
    player endon("disconnect");
    if( !self areYouSure() )
        return;

    counter = 0;

    amount = value / 250;
    multi  = 10 / amount;
    round  = multi + "";
    //self thread progressbar( 0, 100, int(round[0]), .1); 

    for(e=0;e<amount;e++)
    {
        for(i=0;i<250;i++)
            player incrementbgbtokensgained();

        player.var_f191a1fc = self.var_f191a1fc + int(value / amount);
        player reportlootreward("3", int(value / amount));
        UploadStats(player); 
        counter = counter + 250;
        self iPrintLnBold("Liquid Divinium Given: " + counter);
        wait 1.1;
    }
}

give10kLiquid(player)
{
    player giveLiquid( 10000, player );
}

unlockAchievements(player)
{
    self endon("disconnect");
    if( !self areYouSure() )
        return;

    self thread progressbar( 0, 100, 1, .1);    
    foreach(achivement in level.achievements)
    {
        player zm_utility::giveachievement_wrapper(achivement);
        wait .1;
    }
    player.unlock_achievements = true;
}

set_all_EE(player)
{
    if( !self areYouSure() )
        return;
    strings = ["DARKOPS_GENESIS_SUPER_EE", "darkops_zod_ee", "darkops_factory_ee", "darkops_castle_ee", "darkops_island_ee", "darkops_stalingrad_ee", 
    "darkops_genesis_ee", "darkops_zod_super_ee", "darkops_factory_super_ee", "darkops_castle_super_ee", "darkops_island_super_ee", "darkops_stalingrad_super_ee"];
    
    result = 1;
    if( result == int( player GetDStat("PlayerStatsList", "DARKOPS_GENESIS_SUPER_EE", "StatValue") ))  
        result = 0;
    
    foreach(string in strings)
        player SetDStat("playerstatslist", string, "statValue", result);
    player refreshMenuToggles();
}

max_weapon_level( skip = false, player )
{
    self endon("disconnect");
    
    if( !skip )
    {
        if( !self areYouSure() )
            return;
    }
    
    if(!isDefined( player.max_weapons ) || skip )
        player.max_weapons = true;
    else 
        player.max_weapons = undefined;
        
    for(e=0;e<player.weapons.size;e++)
    {
        foreach( weapon in player.weapons[e] )
        {
            index = GetBaseWeaponItemIndex( GetWeapon( weapon.id ) );
            player SetDStat( "ItemStats", index, "xp", !isDefined(player.max_weapons) ? 0 : 665535 );
        }
    }
    player refreshMenuToggles();
}
