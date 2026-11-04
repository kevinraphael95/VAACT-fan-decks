--Quoi ?
-- PIÈGE NORMAL
-- Ne peut être activé QUE pendant la Main Phase de l'adversaire (MP1 ou MP2)
-- Effet : l'adversaire ne peut plus activer d'effet, et doit terminer sa Main Phase
--         (une fois que les effets déjà en chaîne, activés AVANT cette carte, sont résolus)

local s,id = GetID()

function s.initial_effect(c)

	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)

	-- CONDITION D'ACTIVATION : uniquement pendant la Main Phase de l'ADVERSAIRE
	e1:SetCondition(s.actcon)

	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

--------------------------------------------------
-- CONDITION : vérifie qu'on est bien dans la Main Phase adverse
--------------------------------------------------
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	local phase = Duel.GetCurrentPhase()
	local turnplayer = Duel.GetTurnPlayer()
	-- turnplayer ~= tp  -->  c'est le tour de l'ADVERSAIRE (pas le tien)
	-- phase == PHASE_MAIN ou PHASE_MAIN2  -->  Main Phase 1 ou Main Phase 2
	return turnplayer ~= tp and (phase == PHASE_MAIN or phase == PHASE_MAIN2)
end

--------------------------------------------------
-- OPERATION : ce qui se passe à la résolution du piège
--------------------------------------------------
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op = 1 - tp -- l'adversaire (celui qui va être bloqué)

	-- ÉTAPE 1 : on empêche l'adversaire d'activer le moindre effet
	-- jusqu'à la fin du tour actuel
	local e2 = Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetTargetRange(0,1)          -- 0 = n'affecte pas ton camp / 1 = affecte le camp adverse
	e2:SetReset(RESET_PHASE+PHASE_END) -- l'effet disparaît à la fin du tour (End Phase)
	Duel.RegisterEffect(e2,op)

	-- ÉTAPE 2 : une fois les effets déjà en chaîne résolus (ça se fait automatiquement,
	-- le moteur termine toujours la chaîne en cours avant de continuer),
	-- on force le passage direct à la End Phase
	Duel.ChangePhase(PHASE_END)
end
