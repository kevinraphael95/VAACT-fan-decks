--Orichalcos Aristeros
local s,id=GetID()
function s.initial_effect(c)
	-- === AJOUT AUTO : considérée comme la carte officielle (ID 170000169) ===
	local e_add_code = Effect.CreateEffect(c)
	e_add_code:SetType(EFFECT_TYPE_SINGLE)
	e_add_code:SetCode(EFFECT_ADD_CODE)
	e_add_code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e_add_code:SetValue(170000169)
	c:RegisterEffect(e_add_code)
	-- =====================================================================
	-- Ne peut pas être Invoquée Spécialement d'une autre manière
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(function(e,se,sp,st) return se:GetHandler():IsCode(170000167) end) -- Uniquement par Shunoros
	c:RegisterEffect(e1)

	-- Change la cible d'attaque
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.cbcon)
	e2:SetOperation(s.cbop)
	c:RegisterEffect(e2)

	-- Shunoros perd de l'ATK après le combat
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLED)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)

	-- Détruite si Shunoros quitte le terrain
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(s.descon)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)

	-- Indestructible tant que Shunoros est là
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_INDESTRUCTABLE)
	e5:SetCondition(s.atcon)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
s.listed_names={170000167} -- Shunoros
function s.atfilter(c)
	return c:IsFaceup() and c:IsCode(170000167)
end
function s.atcon(e)
	return Duel.IsExistingMatchingCard(s.atfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.cbcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.GetAttacker()~=nil
end
function s.cbop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.ChangeAttackTarget(c)
	local b=Duel.GetAttacker()
	if b then
		local def=b:GetAttack()+300
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetValue(def)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
	end
end
function s.filter(c)
	return c:IsFaceup() and c:IsCode(170000167) and c:GetAttack()~=0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-e:GetHandler():GetDefense())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.desfilter(c,tp)
	return c:IsCode(170000167) and c:IsPreviousPosition(POS_FACEUP)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.desfilter,1,nil,tp)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end