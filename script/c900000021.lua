--Le gant avec les 5 cailloux dangereux
-- MAGIE NORMALE
-- Si vous contrôlez un Monstre Normal avec 3000 ATK ou plus :
-- détruisez la moitié des monstres sur le terrain de l'adversaire (min. 1, arrondi à l'inférieur)
-- et l'adversaire envoie la moitié des monstres de son Deck au cimetière (il choisit lesquels).

local s,id = GetID()

function s.initial_effect(c)
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.actcon)   -- condition : contrôler un Monstre Normal 3000+ ATK
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

--------------------------------------------------
-- CONDITION D'ACTIVATION : posséder un Monstre Normal avec 3000 ATK ou plus
--------------------------------------------------
function s.normalatkfilter(c)
	return c:IsType(TYPE_NORMAL) and c:GetAttack() >= 3000
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.normalatkfilter,tp,LOCATION_MZONE,0,1,nil)
end

--------------------------------------------------
-- TARGET : vérifie qu'il existe au moins 1 monstre adverse sur le terrain
--------------------------------------------------
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local op = 1-tp
		return Duel.IsExistingMatchingCard(nil,op,LOCATION_MZONE,0,1,nil)
	end
end

--------------------------------------------------
-- OPERATION : détruit la moitié des monstres sur le terrain adverse,
-- puis envoie la moitié du Deck adverse au cimetière (l'adversaire choisit)
--------------------------------------------------
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op = 1-tp

	-------------------------------------------------
	-- PARTIE 1 : destruction de la moitié des monstres sur le terrain
	-------------------------------------------------
	local fieldmonsters = Duel.GetMatchingGroup(nil,op,LOCATION_MZONE,0,nil)
	local fcount = fieldmonsters:GetCount()
	if fcount > 0 then
		-- moitié arrondie à l'inférieur, minimum 1
		local todestroy = math.max(1, math.floor(fcount/2))
		local dg = fieldmonsters:RandomSelect(op,todestroy)
		-- "RandomSelect" choisit au hasard ; remplace par une sélection manuelle si tu préfères
		Duel.Destroy(dg,REASON_EFFECT)
	end

	-------------------------------------------------
	-- PARTIE 2 : moitié du Deck adverse envoyée au cimetière, choisie par l'adversaire
	-------------------------------------------------
	local deckcount = Duel.GetMatchingGroupCount(nil,op,LOCATION_DECK,0,nil)
	if deckcount > 0 then
		local togrindeck = math.max(1, math.floor(deckcount/2))
		local deckcards = Duel.GetMatchingGroup(nil,op,LOCATION_DECK,0,nil)
		-- op:Select = c'est l'ADVERSAIRE (op) qui choisit lesquelles partent au cimetière
		local sg = deckcards:Select(op,togrindeck,togrindeck,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
