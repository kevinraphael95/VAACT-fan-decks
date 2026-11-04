--J'aime pas lire
-- MAGIE DE TERRAIN
-- Annule les effets de tous les monstres sur le terrain (y compris les monstres pendule),
-- SAUF les monstres invoqués depuis l'Extra Deck.

local s,id = GetID()

function s.initial_effect(c)
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE_EFFECT)      -- annule les effets des monstres ciblés
	e1:SetRange(LOCATION_FZONE)            -- cette magie de terrain doit être active en Zone Magie/Piège de Terrain
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE) -- s'applique à tous les monstres sur le terrain, des deux côtés
	e1:SetCondition(s.condition)           -- filtre : lesquels sont VRAIMENT affectés
	c:RegisterEffect(e1)
end

--------------------------------------------------
-- CONDITION : exclut les monstres venant de l'Extra Deck
--------------------------------------------------
function s.condition(e,c)
	-- "c" ici est le monstre potentiellement affecté (appelé pour chaque monstre sur le terrain)
	return c and not c:IsExtraDeckMonster()
end
