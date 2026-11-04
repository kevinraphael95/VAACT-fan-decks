local s,id=GetID()
function s.initial_effect(c)
    -- Activer la carte
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,nil) 
           and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,1-tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,PLAYER_ALL,LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Choix du joueur 1 (Le propriétaire/activateur de la carte)
    local p1_choice
    local p1_can_rm = Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,nil)
    if p1_can_rm then
        p1_choice = Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    else
        p1_choice = 1 -- Forcé de payer les LP si impossible de bannir
        Duel.PayLPCost(tp,2000)
    end

    if p1_choice == 0 then
        local g1=Duel.GetDecktopGroup(tp,1)
        if #g1>0 then
            Duel.DisableShuffleCheck()
            Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)
        end
    else
        Duel.PayLPCost(tp,2000)
    end

    -- Choix du joueur 2 (L'adversaire)
    local p2_choice
    local p2_can_rm = Duel.IsExistingMatchingCard(Card.IsAbleToRemove,1-tp,LOCATION_DECK,0,1,nil)
    if p2_can_rm then
        p2_choice = Duel.SelectOption(1-tp,aux.Stringid(id,0),aux.Stringid(id,1))
    else
        p2_choice = 1 -- Forcé de payer les LP si impossible de bannir
        Duel.PayLPCost(1-tp,2000)
    end

    if p2_choice == 0 then
        local g2=Duel.GetDecktopGroup(1-tp,1)
        if #g2>0 then
            Duel.DisableShuffleCheck()
            Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)
        end
    else
        Duel.PayLPCost(1-tp,2000)
    end
end
