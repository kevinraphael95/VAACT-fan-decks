--J'aime pas ce que je comprend pas (les pendules)
-- PIÈGE NORMAL
-- Effet 1 (activation depuis le terrain) : détruit toutes les cartes pendule sur le terrain
-- Effet 2 (depuis le cimetière) : bannir cette carte pour faire le même effet

local s,id = GetID()

--------------------------------------------------
-- INITIALISATION : on enregistre les deux effets de la carte
--------------------------------------------------
function s.initial_effect(c)

	-- ===== EFFET 1 : activation normale du piège =====
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)   -- effet d'activation classique (piège/magie)
	e1:SetCode(EVENT_FREE_CHAIN)       -- s'active librement, comme un piège normal
	e1:SetTarget(s.target)             -- fonction qui vérifie qu'on PEUT activer
	e1:SetOperation(s.operation)       -- fonction qui fait l'effet une fois résolu
	c:RegisterEffect(e1)

	-- ===== EFFET 2 : activable depuis le cimetière =====
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)   -- effet "à volonté" (pas une activation classique)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)        -- ne fonctionne QUE si la carte est au cimetière
	e2:SetCountLimit(1)                -- utilisable une seule fois par tour
	e2:SetCost(s.gcost)                -- le coût à payer (se bannir soi-même)
	e2:SetTarget(s.target)             -- même vérification que l'effet 1
	e2:SetOperation(s.operation)       -- même résultat que l'effet 1
	c:RegisterEffect(e2)
end

--------------------------------------------------
-- FILTRE : définit ce qu'on va détruire
-- (toute carte pendule présente sur le terrain, peu importe le camp)
--------------------------------------------------
function s.filter(c)
	return c:IsPendulumCard() and c:IsOnField()
end

--------------------------------------------------
-- TARGET : vérifie si l'effet PEUT s'activer
-- (il faut qu'il existe au moins une carte pendule sur le terrain)
--------------------------------------------------
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- chk==0 : le jeu demande juste "est-ce que ça peut s'activer ?"
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	end
	-- pas besoin de choisir de cible manuellement ici : l'effet touche TOUTES les cartes pendule
end

--------------------------------------------------
-- COÛT (uniquement pour l'effet depuis le cimetière) :
-- bannir cette carte pour payer le coût
--------------------------------------------------
function s.gcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true -- le coût est toujours payable (rien à vérifier avant)
	end
	-- chk==1 : on paye réellement le coût maintenant
	Duel.Hint(HINT_CARD,tp,e:GetHandler():GetCode()) -- affiche la carte concernée
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST) -- bannit la carte face recto
end

--------------------------------------------------
-- OPERATION : ce qui se passe réellement quand l'effet se résout
-- (détruire toutes les cartes pendule trouvées)
--------------------------------------------------
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- on récupère toutes les cartes qui correspondent au filtre, au moment de la résolution
	local g = Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g > 0 then
		Duel.HintSelection(g)          -- montre visuellement les cartes concernées
		Duel.Destroy(g,REASON_EFFECT)  -- les détruit
	end
end
