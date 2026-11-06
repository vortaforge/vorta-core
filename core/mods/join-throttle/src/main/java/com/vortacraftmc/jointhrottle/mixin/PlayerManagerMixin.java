package com.vortacraftmc.jointhrottle.mixin;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import com.mojang.authlib.GameProfile;
import com.vortacraftmc.jointhrottle.JoinThrottle;
import net.minecraft.server.PlayerManager;
import net.minecraft.text.Text;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

import java.net.SocketAddress;

@Mixin(PlayerManager.class)
public abstract class PlayerManagerMixin {

    /**
     * checkCanJoin returns the disconnect reason (or null to let the player in).
     * Returning ours at HEAD makes vanilla kick the client during login.
     */
    @Inject(method = "checkCanJoin", at = @At("HEAD"), cancellable = true)
    private void jointhrottle$checkCanJoin(SocketAddress address, GameProfile profile,
                                           CallbackInfoReturnable<Text> cir) {
        String reason = JoinThrottle.check(address);
        if (reason != null) {
            cir.setReturnValue(Text.literal(reason));
        }
    }
}
