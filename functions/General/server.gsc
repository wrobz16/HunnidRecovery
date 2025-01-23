_actor_damage_override_wrapper(inflictor, attacker, damage, flags, meansOfDeath, weapon, vPoint, vDir, sHitLoc, vDamageOrigin, psOffsetTime, boneIndex, modelIndex, surfaceType, vSurfaceNormal)
{
    zm::actor_damage_override_wrapper(inflictor, attacker, damage, flags, meansOfDeath, weapon, vPoint, vDir, sHitLoc, vDamageOrigin, psOffsetTime, boneIndex, modelIndex, surfaceType, vSurfaceNormal);
    if( !isAlive( self ) )
    {
        attacker notify( "zombie_killed", meansOfDeath );

        //HEIGHT = 30, FORCE = 200 
        if( isDefined( attacker.custom_ragdoll ) )
        {
            forward               = AnglesToForward( ( 0, attacker.angles[1], 0 ) );
            my_velocity           = VectorScale(forward, attacker.ragdoll_force);
            my_velocity_with_lift = (my_velocity[0], my_velocity[1], attacker.ragdoll_height);
        
            self StartRagdoll(1);
            self LaunchRagdoll( my_velocity_with_lift, self.origin );
        }

    }
    
    /*
    if(IsDefined( attacker.extra_gore ))
    {
        self gibZombie( sHitLoc ); 
        fx = SpawnFX( level._effect[ "bloodspurt" ], vPoint, vDir );
        TriggerFX( fx );
    }*/
}

_player_damage_override_wrapper(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
    if(IsAI( eAttacker ))
    {
        if(IsDefined( self.knockback_zombies ))
        {
            forward               = AnglesToForward( ( 0, eAttacker.angles[1], 0 ) );
            my_velocity           = VectorScale(forward, self.knockback_force);
            my_velocity_with_lift = (my_velocity[0], my_velocity[1], self.knockback_height);
        
            self setOrigin( self.origin + (0,0,5) );
            self SetVelocity( my_velocity_with_lift );
        }
    }   

    if(isDefined( self.demiGodmode ))
    {        
        self FakeDamageFrom( vDir );
        return 0;
    }

    if(( isDefined(self.noExplosiveDamage) && self.noExplosiveDamage)  && (sMeansOfDeath == "MOD_SUICIDE" || sMeansOfDeath == "MOD_PROJECTILE" || sMeansOfDeath == "MOD_PROJECTILE_SPLASH" || sMeansOfDeath == "MOD_GRENADE" || sMeansOfDeath == "MOD_GRENADE_SPLASH" || sMeansOfDeath == "MOD_EXPLOSIVE"))
        return 0;

    if(isDefined( level._overridePlayerDamage ))
        nDamage = [[ level._overridePlayerDamage ]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime);
    else   
        nDamage = zm::player_damage_override(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime);
    return nDamage;
}

powerup_special_drop_override()
{
    if( !level flag::get("zombie_drop_powerups") )
    {
        loc = struct::get("teleporter_powerup", "targetname");
        playfx(level._effect["lightning_dog_spawn"], loc.origin);
        playsoundatposition("zmb_hellhound_prespawn", loc.origin);
        wait 1.5;
        playsoundatposition("zmb_hellhound_bolt", loc.origin);
        earthquake(0.5, 0.75, loc.origin, 1000);
        playsoundatposition("zmb_hellhound_spawn", loc.origin);
        wait 1;
        thread zm_utility::play_sound_2d("vox_sam_nospawn");
        self delete();
        return undefined;
    }
    [[ level._original_powerup_special_drop_override ]]();
}