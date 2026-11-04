--C'était mieux avant
-- MAGIE RAPIDE
-- S'active en réponse à l'Invocation (Normale, Spéciale ou Pose) d'un monstre :
-- annule cette Invocation et bannit le monstre concerné.

local s,id = GetID()

function s.initial_effect(c)
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)  -- effet activable "en chaîne", comme une magie rapide classique
	e1:SetCode(EVENT_SUMMON)         -- se déclenche sur une tentative d'Invocation Normale
	e1:SetRange(LOCATION_HAND+LOCATION_SZONE) -- activable depuis la main ou le terrain
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

	-- Même effet, mais pour les autres types d'invocation
	local e2 = e1:Clone()
	e2:SetCode(EVENT_SPSUMMON)       -- Invocation Spéciale
	c:RegisterEffect(e2)

	local e3 = e1:Clone()
	e3:SetCode(EVENT_FLIPSUMMON)     -- Invocation Retournement
	c:RegisterEffect(e3)

	local e4 = e1:Clone()
	e4:SetCode(EVENT_MSET)           -- Pose (Set)
	c:RegisterEffect(e4)
end

--------------------------------------------------
-- TARGET : on vérifie qu'il y a bien un monstre en train d'être invoqué, et on le cible
--------------------------------------------------
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc = eg:GetFirst() -- le monstre concerné par l'Invocation en cours
	if chk==0 then
		return tc and tc:IsRelateToEffect(e) and tc:IsSummonable(true) ~= nil
	end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,tc,1,0,0)
end

--------------------------------------------------
-- OPERATION : annule l'Invocation, puis bannit le monstre
--------------------------------------------------
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc = Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.NegateSummon(tc)              -- annule l'Invocation en cours
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) -- bannit le monstre
	end
end
