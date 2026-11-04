local s,id=GetID()
function s.initial_effect(c)
    -- Traiter comme un monstre Normal
    c:EnableReviveLimit()
    c:SetType(TYPE_MONSTER + TYPE_NORMAL)
    c:SetLevel(1)
    c:SetAttribute(ATTRIBUTE_EARTH) -- ou un autre attribut de ton choix
    c:SetRace(RACE_ROCK) -- ou une autre race
    c:SetBaseATK(0)
    c:SetBaseDEF(0)

    -- Effet : Quand cette carte est invoquée (Normalement ou Spécialement), lancer une pièce
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_COIN)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL + EFFECT_FLAG_DELAY)
    e1:SetTarget(s.cointg)
    e1:SetOperation(s.coinop)
    c:RegisterEffect(e1)

    -- Effet pour l'invocation spéciale
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
end

-- Fonction cible pour le lancer de pièce
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end

-- Fonction d'opération pour le lancer de pièce
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_COIN,tp,aux.Stringid(id,1))
    local res=Duel.TossCoin(tp,1)
    if res==1 then -- Face
        Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
        local op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
        if op==0 then -- Bannir une carte de la main ou du terrain
            local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE+LOCATION_HAND,1,1,nil)
            if #g>0 then
                Duel.Remove(g:GetFirst(),POS_FACEUP,REASON_EFFECT)
            end
        else -- Payer 1000 LP
            Duel.PayLPCost(tp,1000)
        end
    end
end
