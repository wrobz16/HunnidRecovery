godmode_all()
{
    if(!isDefined( self.godmode_all ))
    {
        self.godmode_all = true;
        self.demiGodmode = undefined;
        self EnableInvulnerability();
        for(i=0;i<level.players.size;i++)
        {
            player = level.players[i];
            if(player != self)
                player EnableInvulnerability();
        }
    }
    else
    {
        self.godmode_all = undefined;
        self DisableInvulnerability();
        for(i=0;i<level.players.size;i++)
        {
            player = level.players[i];
            if(player != self)
                player DisableInvulnerability();
        }
    }
}

infinite_ammo_all()
{
    if(!isDefined( self.infinite_ammo_all ))
    {
        self.infinite_ammo_all = true;
        self thread infinite_ammo_monitor();
    }
    else
    {
        self.infinite_ammo_all = undefined;
    }
}

infinite_ammo_monitor()
{
    self endon("disconnect");

    while( isDefined( self.infinite_ammo_all ) )
    {
        for(i=0;i<level.players.size;i++)
        {
            player = level.players[i];
            weapon = player getCurrentWeapon();
            if( weapon == level.weaponNone )
                continue;

            player setWeaponAmmoClip( weapon, weapon.clipSize );
            player GiveMaxAmmo( weapon );
        }
        wait 0.05;
    }
}