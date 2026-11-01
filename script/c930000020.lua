--Mirror Knight Calling
local s,id=GetID()
function s.initial_effect(c)
	-- === AJOUT AUTO : considérée comme la carte officielle (ID 170000174) ===
	local e_add_code = Effect.CreateEffect(c)
	e_add_code:SetType(EFFECT_TYPE_SINGLE)
	e_add_code:SetCode(EFFECT_ADD_CODE)
	e_add_code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e_add_code:SetValue(170000174)
	c:RegisterEffect(e_add_code)
	-- =====================================================================
	c:EnableReviveLimit()
	
	-- Invoque 4 jetons lors de l'Invocation Rituelle
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	
	-- Place un compteur sur les jetons qui n'en ont pas
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63253763,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	
	-- Effet d'égalisation d'ATK pendant le combat
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetCondition(s.con)
	e3:SetOperation(s.op)
	e3:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e3)
end

s.listed_names={930000021} -- Mirror Knight Token

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsRitualSummoned()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,4,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,4,tp,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- Vérifie l'espace pour les jetons
	if Duel.GetLocationCount(tp,LOCATION_MZONE) < 4 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) 
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,930000021,0x530,TYPES_TOKEN,0,0,1,RACE_WARRIOR,ATTRIBUTE_DARK) then return end
		
	local g=Group.CreateGroup()
	for i=1,4 do
		local token=Duel.CreateToken(tp,930000021)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		g:AddCard(token)
		-- Effet de protection (retire le compteur à la place de la destruction)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EFFECT_DESTROY_REPLACE)
		e1:SetTarget(s.reptg)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
	Duel.BreakEffect()
	
	-- Ajoute 1 Compteur Bouclier (0x1106) à chaque jeton
	g:ForEach(function(tc)
		tc:AddCounter(0x1106,1)
	end)
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_REPLACE) and e:GetHandler():GetCounter(0x1106)>0 end
	e:GetHandler():RemoveCounter(tp,0x1106,1,REASON_EFFECT)
	return true
end

function s.filter(c,ct)
	return c:GetCounter(0x1106)==ct and c:IsFaceup() and c:IsCode(930000021)
end

function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil,0) end
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil,0)
	g:ForEach(function(tc)
		tc:AddCounter(0x1106,1)
	end)
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not d then return false end
	local g=Group.FromCards(a,d)
	return g:IsExists(s.filter,1,nil,1)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not d then return end
	local g=Group.FromCards(a,d):Filter(s.filter,nil,1)
	g:ForEach(function(tc)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		if tc==a then
			e1:SetValue(d:GetAttack())
		else
			e1:SetValue(a:GetAttack())
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
	end)
end