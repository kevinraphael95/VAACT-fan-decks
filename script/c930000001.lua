--オレイカルコス・シュノロス (Anime)
--Orichalcos Shunoros (Anime)
local s,id=GetID()
function s.initial_effect(c)
	-- === AJOUT AUTO : considérée comme la carte officielle (ID 170000167) ===
	local e_add_code = Effect.CreateEffect(c)
	e_add_code:SetType(EFFECT_TYPE_SINGLE)
	e_add_code:SetCode(EFFECT_ADD_CODE)
	e_add_code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e_add_code:SetValue(170000167)
	c:RegisterEffect(e_add_code)
	-- =====================================================================
	c:EnableReviveLimit()
	--Must be Special Summoned by the effect of Orichalcos Kyutora
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--ATK goes down after battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(s.statcon)
	e2:SetOperation(s.statop)
	c:RegisterEffect(e2)
	--DEF goes down after battle
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLED)
	e3:SetCondition(s.statcon2)
	e3:SetOperation(s.statop2)
	c:RegisterEffect(e3)
	--Summon Divine Serpent Geh on destruction
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetCondition(s.dscon)
	e4:SetTarget(s.dstg)
	e4:SetOperation(s.dsop)
	c:RegisterEffect(e4)
	--Special Summon Aristeros/Dexia depuis l'Extérieur du Duel
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(62892347,0))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_SUMMON_SUCCESS)
	e6:SetTarget(s.sptg)
	e6:SetOperation(s.spop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e7)
	local e8=e6:Clone()
	e8:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e8)
end
s.listed_names={82103466, 170000169, 170000168} -- Aristeros et Dexia

function s.statcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc==nil then return false end
	return bc:GetPosition()==POS_FACEUP_ATTACK or bc:GetPosition()==POS_FACEDOWN_ATTACK
end
function s.statop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	local atk=bc:GetAttack()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e:GetHandler():RegisterEffect(e1)
end
function s.statcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc==nil then return false end
	return bc:GetPosition()==POS_FACEUP_DEFENSE or bc:GetPosition()==POS_FACEDOWN_DEFENSE
end
function s.statop2(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	local def=bc:GetDefense()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-def)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e:GetHandler():RegisterEffect(e1)
end
function s.splimit(e,se,sp,st)
	local code=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_CODE)
	return se:GetHandler():IsCode(170000166) or code==170000166
end
function s.dscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and e:GetHandler():GetPreviousAttackOnField()==0 and Duel.GetLP(tp)>=10000
end
function s.filter(c,e,tp)
	return c:IsCode(82103466) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.dstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_HAND)
end
function s.dsop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK|LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK|LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	-- Création de Dexia (170000168)
	local tc1=Duel.CreateToken(tp,170000168)
	-- Création de Aristeros (170000169)
	local tc2=Duel.CreateToken(tp,170000169)
	
	if tc1 and tc2 then
		Duel.SpecialSummonStep(tc1,0,tp,tp,true,false,POS_FACEUP)
		Duel.SpecialSummonStep(tc2,0,tp,tp,true,false,POS_FACEUP)
		Duel.SpecialSummonComplete()
	end
end