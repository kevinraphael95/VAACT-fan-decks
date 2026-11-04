--Kévin
-- MONSTRE - Non Invocable/Posable Normalement
-- Effet 1 : Invocation Spéciale depuis la main si un monstre est Invoqué (Normal ou Spécial)
-- Effet 2 : Intouchable + Indestructible par effets ADVERSES tant qu'en Position de Défense
-- Effet 3 (Effet Rapide, 1x/tour) : mélange les mains des deux joueurs dans le Deck, repioche autant
-- Effet 4 : si ciblée en Position d'Attaque par une attaque OU un effet adverse -> renvoyée en main

local s,id = GetID()

function s.initial_effect(c)

	-------------------------------------------------
	-- EFFET 0 : ne peut pas être Invoquée Normalement ni Posée
	-------------------------------------------------
	local e0 = Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_SUMMON)   -- interdit l'Invocation Normale
	c:RegisterEffect(e0)

	local e0b = e0:Clone()
	e0b:SetCode(EFFECT_CANNOT_MSET)    -- interdit la Pose (Set)
	c:RegisterEffect(e0b)

	-------------------------------------------------
	-- EFFET 1 : Invocation Spéciale depuis la main
	-- (se déclenche quand N'IMPORTE QUEL monstre est Invoqué, par n'importe quel joueur)
	-------------------------------------------------
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0)) -- texte de confirmation "Voulez-vous Invoquer Spécialement Kévin ?"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_SUMMON_SUCCESS)      -- Invocation Normale réussie
	e1:SetRange(LOCATION_HAND)            -- ne marche que si Kévin est dans la main
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	local e1b = e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)   -- + Invocation Spéciale réussie
	c:RegisterEffect(e1b)

	-------------------------------------------------
	-- EFFET 2 : Intouchable tant qu'en Position de Défense (face recto)
	-- (uniquement contre les effets de l'ADVERSAIRE)
	-------------------------------------------------
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)   -- 0=n'affecte pas vos propres effets / 1=bloque ceux de l'adversaire
	e2:SetCondition(s.defcon)
	c:RegisterEffect(e2)

	-- EFFET 3 : Indestructible par effet, même condition, même restriction
	local e3 = e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_DESTROYED_BY_EFFECT)
	c:RegisterEffect(e3)

	-------------------------------------------------
	-- EFFET 4 (Effet Rapide, 1x/tour) : mélange les mains, repioche autant
	-------------------------------------------------
	local e4 = Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_QUICK_O)   -- effet rapide "à volonté" (comme une carte magie rapide)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)                -- 1 fois par tour
	e4:SetTarget(s.eqtg)
	e4:SetOperation(s.eqop)
	c:RegisterEffect(e4)

	-------------------------------------------------
	-- EFFET 5 : ciblée en Position d'Attaque -> renvoyée en main
	-------------------------------------------------
	-- Cas A : ciblée par une attaque adverse
	local e5 = Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.atkcon)
	e5:SetOperation(s.bounceop)
	c:RegisterEffect(e5)

	-- Cas B : ciblée par un effet adverse (carte, monstre, magie, piège...)
	local e6 = e5:Clone()
	e6:SetCode(EVENT_CARD_TARGET)
	e6:SetCondition(s.atktgcon)
	c:RegisterEffect(e6)
end

-------------------------------------------------
-- FONCTIONS DE L'EFFET 1 (Invocation Spéciale depuis la main)
-------------------------------------------------
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- chk==1 : on propose vraiment le choix au joueur
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	-- on revérifie que Kévin est toujours en main au moment de la résolution
	if c:IsLocation(LOCATION_HAND) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

-------------------------------------------------
-- CONDITION DES EFFETS 2 & 3 (protection en Position de Défense)
-------------------------------------------------
function s.defcon(e)
	local c = e:GetHandler()
	return c:IsFaceup() and c:IsPosition(POS_DEFENSE)
end

-------------------------------------------------
-- FONCTIONS DE L'EFFET 4 (mélange des mains + repioche)
-------------------------------------------------
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- rien à cibler, l'effet touche automatiquement les deux joueurs
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local nb = {} -- nombre de cartes en main de chaque joueur, mémorisé AVANT le mélange
	for p=0,1 do
		local hand = Duel.GetMatchingGroup(nil,p,LOCATION_HAND,0,nil)
		nb[p] = hand:GetCount()
		if nb[p] > 0 then
			-- "2" = renvoyer les cartes dans le Deck en les mélangeant directement
			Duel.SendtoDeck(hand,nil,2,REASON_EFFECT)
		end
	end
	-- chaque joueur repioche le même nombre de cartes qu'il avait avant
	for p=0,1 do
		if nb[p] > 0 then
			Duel.Draw(p,nb[p],REASON_EFFECT)
		end
	end
end

-------------------------------------------------
-- FONCTIONS DE L'EFFET 5 (renvoi en main si ciblée en Position d'Attaque)
-------------------------------------------------
-- Cas A : ciblée par une attaque
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	local attacker = eg:GetFirst() -- le monstre qui attaque
	return c:IsPosition(POS_ATTACK) and attacker and attacker:GetBattleTarget()==c
end

-- Cas B : ciblée par un effet adverse
function s.atktgcon(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	return c:IsPosition(POS_ATTACK) and eg:IsContains(c) and rp~=tp
end

-- Opération commune : renvoyer Kévin en main
function s.bounceop(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsPosition(POS_ATTACK) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
