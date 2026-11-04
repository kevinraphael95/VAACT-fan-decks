--Trichula
-- MONSTRE SYNCRO
-- Quand invoqué par Synchro : bannit aléatoirement 1 carte de l'adversaire
-- depuis sa main, 1 depuis son terrain, et 1 depuis son cimetière.
-- Quand cette carte quitte le terrain : envoie aléatoirement 1 carte de
-- l'adversaire au cimetière depuis sa main, et 1 depuis son terrain.
-- Vous pouvez bannir cette carte depuis le cimetière : piochez autant de
-- cartes que l'adversaire a de cartes bannies.

local s,id = GetID()

function s.initial_effect(c)

	-------------------------------------------------
	-- EFFET 1 : à l'Invocation Synchro, bannissement aléatoire (main+terrain+cimetière)
	-------------------------------------------------
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.syncon)         -- vérifie que c'est bien une Invocation Synchro
	e1:SetOperation(s.remop)
	c:RegisterEffect(e1)

	-------------------------------------------------
	-- EFFET 2 : quand cette carte quitte le terrain, envoi aléatoire au cimetière
	-------------------------------------------------
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TRIGGER_F)  -- effet qui se déclenche même après le départ de la carte
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)

	-------------------------------------------------
	-- EFFET 3 : depuis le cimetière, bannir pour piocher
	-------------------------------------------------
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetCost(s.gcost)
	e3:SetTarget(s.gtarget)
	e3:SetOperation(s.drawop)
	c:RegisterEffect(e3)
end

--------------------------------------------------
-- CONDITION EFFET 1 : uniquement si Invoquée par Synchro
--------------------------------------------------
function s.syncon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_SYNCHRO) and eg:IsContains(e:GetHandler())
end

--------------------------------------------------
-- OPERATION EFFET 1 : bannit 1 carte au hasard de chaque zone adverse (main, terrain, cimetière)
--------------------------------------------------
function s.remop(e,tp,eg,ep,ev,re,r,rp)
	local op = 1-tp

	local hand = Duel.GetMatchingGroup(nil,op,LOCATION_HAND,0,nil)
	if hand:GetCount() > 0 then
		Duel.Remove(hand:RandomSelect(op,1),POS_FACEUP,REASON_EFFECT)
	end

	local field = Duel.GetMatchingGroup(nil,op,LOCATION_ONFIELD,0,nil)
	if field:GetCount() > 0 then
		Duel.Remove(field:RandomSelect(op,1),POS_FACEUP,REASON_EFFECT)
	end

	local grave = Duel.GetMatchingGroup(nil,op,LOCATION_GRAVE,0,nil)
	if grave:GetCount() > 0 then
		Duel.Remove(grave:RandomSelect(op,1),POS_FACEUP,REASON_EFFECT)
	end
end

--------------------------------------------------
-- OPERATION EFFET 2 : envoi aléatoire au cimetière (main + terrain adverses)
--------------------------------------------------
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local op = 1-tp

	local hand = Duel.GetMatchingGroup(nil,op,LOCATION_HAND,0,nil)
	if hand:GetCount() > 0 then
		Duel.SendtoGrave(hand:RandomSelect(op,1),REASON_EFFECT)
	end

	local field = Duel.GetMatchingGroup(nil,op,LOCATION_ONFIELD,0,nil)
	if field:GetCount() > 0 then
		Duel.SendtoGrave(field:RandomSelect(op,1),REASON_EFFECT)
	end
end

--------------------------------------------------
-- COUT EFFET 3 : bannir cette carte depuis le cimetière
--------------------------------------------------
function s.gcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

--------------------------------------------------
-- TARGET EFFET 3 : rien à cibler, juste vérifier qu'on peut piocher
--------------------------------------------------
function s.gtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

--------------------------------------------------
-- OPERATION EFFET 3 : pioche autant que l'adversaire a de cartes bannies
--------------------------------------------------
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local op = 1-tp
	local removed = Duel.GetMatchingGroupCount(nil,op,0,0,LOCATION_REMOVED)
	if removed > 0 then
		Duel.Draw(tp,removed,REASON_EFFECT)
	end
end
