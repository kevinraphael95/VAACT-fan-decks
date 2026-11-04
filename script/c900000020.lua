--Être normal c'est bien
-- MAGIE CONTINUE
-- Tant que cette carte est sur le terrain :
-- 1) les dégâts de combat sont inversés (l'attaquant subit les dégâts, pas le défenseur)
-- 2) les Monstres Normaux peuvent attaquer directement les Points de Vie

local s,id = GetID()

function s.initial_effect(c)

	-------------------------------------------------
	-- EFFET 1 : inversion des dégâts de combat
	-------------------------------------------------
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REVERSE_DAMAGE)   -- inverse qui subit les dégâts de combat
	e1:SetRange(LOCATION_SZONE)         -- actif tant que la carte est sur le terrain
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE) -- s'applique à tous les combats, des deux côtés
	c:RegisterEffect(e1)

	-------------------------------------------------
	-- EFFET 2 : les Monstres Normaux peuvent attaquer directement
	-------------------------------------------------
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE) -- s'applique aux deux joueurs
	e2:SetCondition(s.normalcon)        -- restreint aux Monstres Normaux uniquement
	c:RegisterEffect(e2)
end

--------------------------------------------------
-- CONDITION EFFET 2 : ne s'applique qu'aux Monstres Normaux
--------------------------------------------------
function s.normalcon(e,c)
	return c and c:IsType(TYPE_NORMAL)
end
