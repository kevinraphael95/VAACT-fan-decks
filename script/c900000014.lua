--Pause Toilettes
-- MAGIE RAPIDE
-- Activable uniquement si l'adversaire a activé 5 effets de carte ou plus pendant son tour.
-- "Quittez la table 10 minutes. À votre retour, l'adversaire mélange son terrain dans son Deck
--  parce que vous avez perdu le fil."

local s,id = GetID()

function s.initial_effect(c)

	-------------------------------------------------
	-- COMPTEUR : suit le nombre d'effets activés par CHAQUE joueur ce tour
	-------------------------------------------------
	local e0 = Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EVENT_CHAINING)          -- se déclenche à chaque effet mis en chaîne
	e0:SetRange(LOCATION_HAND+LOCATION_SZONE) -- actif même si la carte est en main (pour compter avant activation)
	e0:SetOperation(s.count)
	c:RegisterEffect(e0)

	-------------------------------------------------
	-- ACTIVATION de la magie rapide elle-même
	-------------------------------------------------
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.actcon)           -- condition : adversaire a activé 5+ effets ce tour
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

--------------------------------------------------
-- COUNT : incrémente un compteur à chaque effet mis en chaîne par le joueur qui vient de jouer
--------------------------------------------------
function s.count(e,tp,eg,ep,ev,re,r,rp)
	-- "rp" = le joueur qui a activé l'effet en chaîne
	if rp==0 then
		s.count0 = (s.count0 or 0) + 1
	else
		s.count1 = (s.count1 or 0) + 1
	end
end

--------------------------------------------------
-- RESET : les compteurs sont remis à zéro à chaque nouveau tour
--------------------------------------------------
function s.reset(e,tp,eg,ep,ev,re,r,rp)
	s.count0 = 0
	s.count1 = 0
end

--------------------------------------------------
-- CONDITION D'ACTIVATION : l'adversaire (le joueur du tour) a activé 5+ effets ce tour
--------------------------------------------------
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	local turnplayer = Duel.GetTurnPlayer()
	local op = 1-tp
	if turnplayer ~= tp then -- c'est bien le tour de l'adversaire
		local count = (turnplayer==0) and (s.count0 or 0) or (s.count1 or 0)
		return count >= 5
	end
	return false
end

--------------------------------------------------
-- OPERATION : l'adversaire mélange son terrain dans son Deck
--------------------------------------------------
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op = 1-tp
	local g = Duel.GetMatchingGroup(nil,op,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount() > 0 then
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT) -- "2" = renvoi mélangé dans le Deck
		Duel.ShuffleDeck(op)
	end
end
