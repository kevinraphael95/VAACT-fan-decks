--Le Cancer
-- MONSTRE GEMINI
-- Traité comme Monstre Normal (face recto sur le terrain et au cimetière),
-- SAUF une fois "re-invoqué" chez l'adversaire (voir Effet 2).
-- Effet 2 : si sur votre terrain, vous pouvez l'invoquer (à nouveau) sur le terrain
--           de l'adversaire ; il devient alors un Monstre à Effet :
--           son PROPRIÉTAIRE perd 1000 LP à chacune de ses End Phases.
-- Ne peut pas être sacrifié pour une Invocation Sacrifice.

local s,id = GetID()

function s.initial_effect(c)

	-------------------------------------------------
	-- EFFET 1 : traité comme Monstre Normal, tant que le flag "re-invoqué" n'est pas posé
	-------------------------------------------------
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetValue(TYPE_NORMAL)
	e1:SetCondition(s.normalcon)
	c:RegisterEffect(e1)

	local e1b = e1:Clone()
	e1b:SetCode(EFFECT_REMOVE_TYPE)
	e1b:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e1b)

	-------------------------------------------------
	-- EFFET 2 : Invocation (façon Normale) sur le terrain de l'adversaire
	-------------------------------------------------
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.gemcon)
	e2:SetTarget(s.gemtg)
	e2:SetOperation(s.gemop)
	c:RegisterEffect(e2)

	-------------------------------------------------
	-- EFFET 3 : LP perdus par le PROPRIÉTAIRE, seulement une fois "re-invoqué"
	-------------------------------------------------
	local e3 = Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.lpcon)
	e3:SetOperation(s.lpop)
	c:RegisterEffect(e3)

	-------------------------------------------------
	-- EFFET 4 : ne peut pas être sacrifié pour une Invocation Sacrifice
	-------------------------------------------------
	local e4 = Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_RELEASE)
	c:RegisterEffect(e4)
end

--------------------------------------------------
-- CONDITION EFFET 1 : "normal" tant que le flag n'a pas été posé
--------------------------------------------------
function s.normalcon(e)
	local c = e:GetHandler()
	return c:GetFlagEffect(id) == 0
end

--------------------------------------------------
-- CONDITION EFFET 2 : la carte doit être sur VOTRE terrain, et pas déjà "re-invoquée"
--------------------------------------------------
function s.gemcon(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	return c:IsControler(tp) and c:GetFlagEffect(id) == 0
end

function s.gemtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

--------------------------------------------------
-- OPERATION EFFET 2 : marque le flag, puis la déplace sur le terrain adverse
--------------------------------------------------
function s.gemop(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	local op = 1-tp
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		c:SetFlagEffect(id,1)  -- bascule définitivement en état "Monstre à Effet"
		Duel.SpecialSummon(c,SUMMON_TYPE_NORMAL,tp,op,false,false,POS_FACEUP)
	end
end

--------------------------------------------------
-- CONDITION EFFET 3 : uniquement une fois le flag posé, à la End Phase du PROPRIÉTAIRE
--------------------------------------------------
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	return c:GetFlagEffect(id) ~= 0 and Duel.GetTurnPlayer() == c:GetOwner()
end

function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	Duel.Damage(c:GetOwner(),1000,REASON_EFFECT)
end
