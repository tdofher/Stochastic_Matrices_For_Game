clear;

allCombos = zeros(5*15,2);
w = 1;

for y = 1:5
    
    for z = 1:15


attackNumber = z;
defenceNumber = y;

stock = zeros(((attackNumber+1)*(defenceNumber+1)));

for n = 1:defenceNumber+1
    
    for m = 1:attackNumber+1
        
        if attackNumber-(m-1) >= 5
            attackDice = 5;
        else
            attackDice = attackNumber-(m-1);
        end
        
        if defenceNumber-(n-1) >= 5
            defenceDice = 5;
        else
            defenceDice = defenceNumber-(n-1);
        end
        if(attackDice > defenceDice)
            diceCompared = defenceDice;
        else
            diceCompared = attackDice;
        end
        
        colToEdit = (n-1)*(attackNumber+1)+(m);
        if(colToEdit > (attackNumber+1)*(defenceNumber+1)-(attackNumber+1) ||...
                mod(colToEdit,attackNumber+1) == 0 )
            stock(colToEdit,colToEdit) = 1;
            
        else
            probs = getRollOdds(attackNumber-(m-1),defenceNumber-(n-1));
            for index = 1:size(probs,2)
                stock(((index-1)+(n-1))*(attackNumber+1)+(diceCompared-(index-1))+(m),colToEdit) = probs(1,index);
            end
        end
        
    end
    
end

initialState = zeros((attackNumber+1)*(defenceNumber+1),1);
initialState(1) = 1;

finalOdds = stock^3*initialState;
winningOdds = sum(finalOdds((attackNumber+1)*(defenceNumber+1)-(attackNumber):(attackNumber+1)*(defenceNumber+1)))
loosingOdds = sum(finalOdds(1:(attackNumber+1)*(defenceNumber+1)-(attackNumber+1)))

        allCombos(w,1) = winningOdds;
        allCombos(w,2) = loosingOdds;

        w = w +1;
    end
end

function rollOdds = getRollOdds(attackNumber,defenceNumber)

if attackNumber >= 5
    attackDice = 5;
else
    attackDice = attackNumber;
end

if defenceNumber >= 5
    defenceDice = 5;
else
    defenceDice = defenceNumber;
end


defenceRolls = roll(defenceDice);
attackRolls = roll(attackDice);

defenceRolls = sort(defenceRolls,2,'descend');
attackRolls = sort(attackRolls,2,'descend');

uniqueDefence = unique(defenceRolls,'rows');
numUniqueD = size(uniqueDefence,1);
defRollProbs = zeros(numUniqueD,defenceDice+1);
defRollProbs(:,1:defenceDice) = uniqueDefence;
for n = 1:numUniqueD
    for i = 1:6^defenceDice
        if(uniqueDefence(n,:) == defenceRolls(i,:))
            defRollProbs(n,defenceDice+1)=defRollProbs(n,defenceDice+1)+1;
        end
    end
end
defRollProbs(:,defenceDice+1) = defRollProbs(:,defenceDice+1)/(6^defenceDice);

uniqueAttack = unique(attackRolls,'rows');
numUniqueA = size(uniqueAttack,1);
attRollProbs = zeros(numUniqueA,attackDice+1);
attRollProbs(:,1:attackDice) = uniqueAttack;
for n = 1:numUniqueA
    for i = 1:6^attackDice
        if(uniqueAttack(n,:) == attackRolls(i,:))
            attRollProbs(n,attackDice+1)=attRollProbs(n,attackDice+1)+1;
        end
    end
end
attRollProbs(:,attackDice+1) = attRollProbs(:,attackDice+1)/(6^attackDice);


defendersKilledTable = zeros(numUniqueA,numUniqueD,2);

if(attackDice > defenceDice)
    diceCompared = defenceDice;
else
    diceCompared = attackDice;
end


for m = 1:numUniqueA
    for n = 1:numUniqueD
        results = uniqueAttack(m,1:diceCompared)-uniqueDefence(n,1:diceCompared);
        defendersKilled = sum(results > 0);
        defendersKilledTable(m,n,1) = defendersKilled;
        defendersKilledTable(m,n,2) = attRollProbs(m,attackDice+1)*defRollProbs(n,defenceDice+1);
    end
end

killGrid = defendersKilledTable(:,:,1);
deathMatrix = zeros(numUniqueA,numUniqueD,diceCompared);
probabilities = zeros(1,diceCompared+1);
for n = 0:diceCompared
    deathMatrix(:,:,n+1) = killGrid == n;
    deathMatrix(:,:,n+1) = deathMatrix(:,:,n+1).*defendersKilledTable(:,:,2);
    probabilities(n+1) = sum(sum(deathMatrix(:,:,n+1)));
end
rollOdds = probabilities;

end

function rollArray = roll(numDice)
allRolls = zeros(6^numDice,numDice);

for n = 0:(6^numDice-1)
    index = 1;
    r = n;
    while r > 0
        allRolls(n,index) = rem(r,6);
        r = (r-rem(r,6))/6;
        index = index +1;
    end
end
allRolls = allRolls+ones(6^numDice,numDice);
rollArray = allRolls;
end
