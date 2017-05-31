%   Falco Enzler 30th May 2017.
%   Time spent coding: an afternoon.
%
%   With more time here are some of the things I would've tried to implement:
%   - Graphic interface
%   - Live autocomplete suggestions
%   - Better classification algorithm (more scoring relative to name)
%   - Handling city name ortographic errors and missing letters
%   - Special character handling ('é' 'à' etc...)
%

clear all;

%Read Tsv file and save it in s structure
fprintf('Learning all cities in North America, give me a sec... \n');
s = tdfread('./cities_canada-usa.tsv', 'tab');

fprintf('Okay I''m ready! Let''s do this! \n');

%As long as user wants to search we continue
KeepGoing = true;
while(KeepGoing)
    
    %Get City search query
    NotString = true;
    CityName = input('What city are you looking for?  ', 's');
    while(NotString)
        %Check validity of input
        if(isa(CityName, 'char'))
            NotString = false;
        else
            CityName = input('Sorry didn''t quite get that, give it another go: ', 's');
        end
    end
    
    Match = 0;
    %Save Ids that correspond most to the entered query
    for i = 1:numel(CityName)
        SavedIds = 0;
        for j = 1:numel(s.name(:,1))
            if(strcmpi(CityName(1:i), s.name(j,1:i)))
                SavedIds = SavedIds + 1;
                Match = Match + 1;
                Ids(i, SavedIds) = j;
            end
        end
    end
    
    %Nothing matched, problem
    if(Match == 0)
        fprintf('\nHmmm... couldn''t figure that name out, sorry, try again! \n\n');
        %Start at the top again
        continue;
    end
    
    %Get Latitude
    NotDouble = true;
    sLatitude = input('Enter Latitude: (enter no if unknown) ', 's');
    %Check validity of input
    while(NotDouble)
        if (strcmpi(sLatitude,'no'))
            GotLatitude = false;
            NotDouble = false;
        else
            GotLatitude = true;
            Latitude = str2double(sLatitude);
            
            if(isnan(Latitude))
                sLatitude = input('Sorry didn''t quite get that, give it another go: ', 's');
            else
                NotDouble = false;
            end
        end
        
    end
    
    %Get Longitude
    NotDouble = true;
    sLongitude = input('Enter Longitude: (enter no if unknown) ', 's');
    %Check validity of input
    while(NotDouble)
        if (strcmpi(sLongitude,'no'))
            GotLongitude = false;
            NotDouble = false;
        else
            GotLongitude = true;
            Longitude = str2double(sLongitude);
            
            if(isnan(Longitude))
                sLongitude = input('Sorry didn''t quite get that, give it another go: ', 's');
            else
                NotDouble = false;
            end
        end
    end
    
    LastLine = numel(Ids(:,1));
    LastId = find(Ids(LastLine, :), 1, 'last');
    
    %Compute differences between goal and what we have
    for i = 1:LastId
        if(GotLatitude)
            DiffLat(1, i) = abs(Latitude - s.lat(Ids(LastLine,i),:));
            %save index
            DiffLat(2, i) = Ids(LastLine,i);
        end
        
        if(GotLongitude)
            DiffLong(1, i) = abs(Longitude - s.long(Ids(LastLine,i),:));
            %save index
            DiffLong(2, i) = Ids(LastLine,i);
        end
    end
    
    %Sort smallest to biggest
    if(GotLatitude)
        SortDiffLat(1,:) = sort(DiffLat(1,:));
        
        %Have ids be rearranged
        for i = 1:numel(SortDiffLat)
            for j = 1:numel(DiffLat(2,:))
                if(SortDiffLat(1,i) == DiffLat(1,j))
                    SortDiffLat(2,i) = DiffLat(2,j);
                end
            end
        end
    end
    
    %Sort smallest to biggest
    if(GotLongitude)
        SortDiffLong(1,:) = sort(DiffLong(1,:));
        
        %Have ids be rearranged
        for i = 1:numel(SortDiffLong)
            for j = 1:numel(DiffLong(2,:))
                if(SortDiffLong(1,i) == DiffLong(1,j))
                    SortDiffLong(2,i) = DiffLong(2,j);
                end
            end
        end
    end
    
    if(GotLatitude && GotLongitude)
        %Let's use pythagore to see who is closest
        for i = 1:numel(DiffLat(2,:))
            Distance(1,i) = sqrt(DiffLat(1,i)^2 + DiffLong(1,i)^2);
            Distance(2,i) = DiffLat(2,i);
        end
        
        %Sort closest to farthest
        SortDistance(1,:) = sort(Distance(1,:));
        
        %Have ids be rearranged
        for i = 1:numel(SortDistance)
            for j = 1:numel(Distance(2,:))
                if(SortDistance(1,i) == Distance(1,j))
                    SortDistance(2,i) = Distance(2,j);
                end
            end
        end
    end
    
    %output best guesses
    if(GotLatitude && GotLongitude)
        fprintf('\nBest guesses, in order of relevance: \n\n');
        for i = 1:numel(SortDistance(2,:))
            fprintf('%s \nCountry: %s \nLatitude : %f \nLongitude : %f \n\n', ...
                s.name(SortDistance(2,i), :), ...
                s.country(SortDistance(2,i),:), ...
                s.lat(SortDistance(2,i),:),  s.long(SortDistance(2,i), :));
        end
    elseif(GotLatitude)
        fprintf('\nBest guesses, in order of relevance: \n\n');
        for i = 1:numel(SortDiffLat(2,:))
            fprintf('%s \nCountry: %s \nLatitude : %f \nLongitude : %f \n\n', ...
                s.name(SortDiffLat(2,i), :), ...
                s.country(SortDiffLat(2,i),:), ...
                s.lat(SortDiffLat(2,i),:),  s.long(SortDiffLat(2,i), :));
        end
    elseif(GotLongitude)
        fprintf('\nBest guesses, in order of relevance: \n\n');
        for i = 1:numel(SortDiffLong(2,:))
            fprintf('%s \nCountry: %s \nLatitude : %f \nLongitude : %f \n\n', ...
                s.name(SortDiffLong(2,i), :), ...
                s.country(SortDiffLong(2,i),:), ...
                s.lat(SortDiffLong(2,i),:),  s.long(SortDiffLong(2,i), :));
        end
    else
        fprintf('\nBest guesses: \n\n');
        for i = 1:LastId
            fprintf('%s \nCountry: %s \nLatitude : %f \nLongitude : %f \n\n', ...
                s.name(Ids(LastLine, i),:), ...
                s.country(Ids(LastLine, i),:), ...
                s.lat(Ids(LastLine, i),:),  s.long(Ids(LastLine, i),:));
        end
    end
    
    %Ask if want to start another search
    answer = input('Want to look for something else? (y/n) ', 's');
    NotUnderstood = true;
    while(NotUnderstood)
        if(strcmp(answer, 'n') || strcmp(answer, 'N') || strcmp(answer, 'No') || strcmp(answer, 'no'))
            KeepGoing = false;
            NotUnderstood = false;
            fprintf('Exiting... bye! \n');
        elseif(strcmp(answer, 'y') || strcmp(answer, 'Y') || strcmp(answer, 'Yes') || strcmp(answer, 'yes'))
            NotUnderstood = false;
            fprintf('Great! Here we go again \n');
            
            %Clear variables before restarting a new search
            clear Ids;
            clear DiffLong;
            clear DiffLat;
            clear SortDiffLong;
            clear SortDiffLat;
            clear Distance;
            clear SortDistance;
            
        else
            answer = input('Sorry I didn''t get that, try again: (y/n)? ', 's');
        end
    end
    
end

