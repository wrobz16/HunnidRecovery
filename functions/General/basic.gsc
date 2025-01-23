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