--Kévin et Dragon Blanc
-- MONSTRE FUSION
-- Ne peut pas être détruit au combat.
-- (Effet Rapide) 1x/tour : ciblez une carte sur le terrain, annulez ses effets jusqu'à la fin du tour.
-- L'adversaire ne peut pas activer la carte ciblée en réponse à cette activation.

local s,id = GetID()

function s.initial_effect(c)

	-- Matériel de Fusion : Kévin + Dragon Blanc aux Yeux Bleus
	c:EnableReviveLimit()
	Fusion.AddProcMixMaterial(c,aux.FilterBoolFunction(Card.IsCode,10000004),Card.IsCode,89631139,1,1)
	-- Adapte les IDs : 10000004 = ID de "Kévin" (mets ici son vrai ID), 89631139 = Blue-Eyes White Dragon

	-------------------------------------------------
	-- EFFET 1 : indestructible au combat
	-------------------------------------------------
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	c:RegisterEffect(e1)

	-------------------------------------------------
	-- EFFET 2 : Effet Rapide, 1x/tour, annule les effets d'une carte ciblée
	-------------------------------------------------
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)     -- Effet Rapide (utilisable comme une magie rapide)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)         -- utilisable tant que le monstre est sur le terrain
	e2:SetCountLimit(1)                 -- 1 fois par tour
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end

--------------------------------------------------
-- TARGET : choix de la carte ciblée sur le terrain (n'importe quel camp)
--------------------------------------------------
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
end

--------------------------------------------------
-- OPERATION : annule les effets de la carte ciblée jusqu'à la End Phase,
-- ET empêche l'adversaire de l'activer en réponse
--------------------------------------------------
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc = Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then

		-- Annule les effets de la carte jusqu'à la fin du tour
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE_EFFECT)
		e1:SetReset(RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)

		-- Empêche l'adversaire de l'activer EN RÉPONSE à cette activation
		-- (bloque toute activation de cette carte tant que la chaîne actuelle n'est pas résolue)
		local e2 = Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetReset(RESET_CHAIN)
		tc:RegisterEffect(e2)
	end
end
