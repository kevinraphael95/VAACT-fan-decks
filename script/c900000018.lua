--Flamed Winged Man
-- MONSTRE FUSION
-- N'est pas affecté par les effets de monstres FEU et VENT.
-- Peut attaquer à nouveau après avoir attaqué un monstre FEU ou VENT.

local s,id = GetID()

function s.initial_effect(c)

	-------------------------------------------------
	-- EFFET 1 : immunité aux effets des monstres FEU et VENT
	-------------------------------------------------
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.immunefilter)  -- filtre : quelles cartes sont bloquées
	c:RegisterEffect(e1)

	-------------------------------------------------
	-- EFFET 2 : attaque supplémentaire après avoir attaqué un monstre FEU ou VENT
	-------------------------------------------------
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(1)                -- 1 attaque supplémentaire
	e2:SetCondition(s.atkcon)     -- seulement si la cible était FEU ou VENT
	e2:SetReset(RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
end

--------------------------------------------------
-- FILTRE EFFET 1 : bloque les effets provenant de monstres FEU ou VENT
--------------------------------------------------
function s.immunefilter(e)
	local ec = e:GetOwner()
	return ec and ec:IsMonster() and (ec:IsAttribute(ATTRIBUTE_FIRE) or ec:IsAttribute(ATTRIBUTE_WIND))
end

--------------------------------------------------
-- CONDITION EFFET 2 : vérifie que le monstre attaqué était FEU ou VENT
--------------------------------------------------
function s.atkcon(e)
	local c = e:GetHandler()
	local bc = c:GetBattleTarget() -- le monstre qui vient d'être attaqué
	return bc and (bc:IsAttribute(ATTRIBUTE_FIRE) or bc:IsAttribute(ATTRIBUTE_WIND))
end
