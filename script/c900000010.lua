--Non t'as pas de cimetière
-- MAGIE CONTINUE
-- "J'oublie ce qu'il y a dans ton cimetière, donc t'as pas le droit de jouer avec."
-- Effet 1 : annule l'activation de tout effet de carte présent au cimetière
-- Effet 2 : toute carte qui devrait aller au cimetière est bannie à la place

local s,id = GetID()

function s.initial_effect(c)

	-------------------------------------------------
	-- EFFET 1 : annule l'activation des effets depuis le cimetière
	-------------------------------------------------
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE_EFFECT)     -- annule les effets des cartes ciblées
	e1:SetRange(LOCATION_SZONE)           -- cette magie continue doit être face recto sur le terrain
	e1:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE) -- cible : cartes dans N'IMPORTE QUEL cimetière (les deux joueurs)
	c:RegisterEffect(e1)

	-------------------------------------------------
	-- EFFET 2 : toute carte qui irait au cimetière est bannie à la place
	-------------------------------------------------
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)  -- redirige "envoi au cimetière" vers ailleurs
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(LOCATION_REMOVED)         -- destination de remplacement : le banni
	e2:SetTargetRange(LOCATION_ONFIELD+LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA) -- affecte les deux joueurs, toutes zones d'origine possibles
	c:RegisterEffect(e2)
end
