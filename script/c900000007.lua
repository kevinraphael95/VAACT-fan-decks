--Perdu ? Moi ? Sérieusement
-- MAGIE RAPIDE
-- Si le propriétaire devrait perdre la partie (LP à 0 ou deck-out) :
-- il ne perd pas, la cause de la défaite est bannie, l'adversaire termine son tour immédiatement

local s,id = GetID()

function s.initial_effect(c)
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_LOSE)  -- flag reconnu par le moteur pour éviter LP=0 / deck-out
	e1:SetTargetRange(1,0)         -- 1 = protège TON camp uniquement
	e1:SetReset(RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)

	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=1-tp
	-- bannit cette carte elle-même comme trace de "la cause neutralisée"
	Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
	-- termine le tour de l'adversaire
	Duel.ChangePhase(PHASE_END)
end
