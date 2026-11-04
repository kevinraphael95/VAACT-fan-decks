--Trouver un travail
-- MAGIE RAPIDE
-- "Les joueurs qui ont un travail perdent 2000 LP."
-- (seul l'adversaire est considéré comme "ayant un travail")
-- Le reste du texte (appeler l'employeur, démission...) est du flavor,
-- non gérable par le moteur : les joueurs l'appliquent eux-mêmes à l'oral.

local s,id = GetID()

--------------------------------------------------
-- INITIALISATION : on enregistre l'effet d'activation
--------------------------------------------------
function s.initial_effect(c)
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)   -- effet d'activation classique
	e1:SetCode(EVENT_FREE_CHAIN)       -- s'active librement, comme une magie rapide normale
	e1:SetOperation(s.operation)       -- fonction exécutée à la résolution
	c:RegisterEffect(e1)
end

--------------------------------------------------
-- OPERATION : ce qui se passe à la résolution de la carte
--------------------------------------------------
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op = 1 - tp -- "op" = l'adversaire du joueur qui a activé la carte

	-- on vérifie que l'adversaire a encore des LP avant d'infliger les dégâts
	-- (évite une erreur si jamais ses LP sont déjà à 0)
	if Duel.GetLP(op) > 0 then
		Duel.Damage(op, 2000, REASON_EFFECT) -- inflige 2000 dégâts à l'adversaire
	end
end
