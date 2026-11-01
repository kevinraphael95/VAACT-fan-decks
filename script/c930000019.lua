--オレイカルコス・ミラー
--Orichalcos Mirror
local s,id=GetID()
function s.initial_effect(c)
	-- === AJOUT AUTO : considérée comme la carte officielle (ID 170000173) ===
	local e_add_code = Effect.CreateEffect(c)
	e_add_code:SetType(EFFECT_TYPE_SINGLE)
	e_add_code:SetCode(EFFECT_ADD_CODE)
	e_add_code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e_add_code:SetValue(170000173)
	c:RegisterEffect(e_add_code)
	-- =====================================================================
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- On vérifie si on a assez de matériel pour le Rituel (Niveau 6)
		return Duel.IsExistingMatchingCard(Card.IsReleasable,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) 
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- On crée le monstre Rituel (Mirror Knight Calling) depuis l'Extérieur du Duel (ID 930000020)
	local tc = Duel.CreateToken(tp, 930000020)
	if not tc then return end
	
	-- Vérification des matériaux
	local mg = Duel.GetRitualMaterial(tp)
	if not mg:CheckWithSumGreater(Card.GetRitualLevel, 6, tc) then return end
	
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
	local mat = mg:SelectWithSumGreater(tp, Card.GetRitualLevel, 6, tc)
	
	if #mat > 0 then
		tc:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		
		-- Invoque la carte créée
		if Duel.SpecialSummon(tc, SUMMON_TYPE_RITUAL, tp, tp, true, false, POS_FACEUP) > 0 then
			tc:CompleteProcedure()
		end
	end
end