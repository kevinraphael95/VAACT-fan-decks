--Invoque le monstre normal que je veux depuis mon deck
-- MAGIE RAPIDE
-- "L'effet de cette carte c'est son nom." -> on fait exactement ce que dit le nom :
-- Invoque Spécialement le Monstre Normal de son choix depuis son Deck.

local s,id = GetID()

--------------------------------------------------
-- INITIALISATION : on enregistre l'effet d'activation
--------------------------------------------------
function s.initial_effect(c)
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)   -- activation classique de magie rapide
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)             -- vérifie qu'on PEUT activer (existe-t-il un monstre normal dans le Deck ?)
	e1:SetOperation(s.operation)       -- ce qui se passe à la résolution
	c:RegisterEffect(e1)
end

--------------------------------------------------
-- FILTRE : ne cible que les Monstres Normaux présents dans le Deck
--------------------------------------------------
function s.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToSpecialSummon()
end

--------------------------------------------------
-- TARGET : vérifie qu'il existe au moins un Monstre Normal invocable dans le Deck
--------------------------------------------------
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
	end
	-- pas de ciblage de carte "Target" classique ici : le choix se fait au moment de la résolution
end

--------------------------------------------------
-- OPERATION : le joueur choisit le Monstre Normal, puis il est Invoqué Spécialement
--------------------------------------------------
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- on récupère tous les Monstres Normaux du Deck
	local g = Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g > 0 then
		-- le joueur choisit lequel il veut parmi ceux trouvés
		local sg = g:Select(tp,1,1,nil)
		if sg:GetCount() > 0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			Duel.ConfirmCards(1-tp,sg) -- montre la carte choisie à l'adversaire
		end
	end
end
