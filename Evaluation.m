function results = Evaluation(metrics)
    figure;
    precisions = [];
    recalls = [];
    
    [r, ~] = size(metrics);
    for i=1:r
        frame = metrics(i,:);
        precision = frame(1)/(frame(1) + frame(2));
        recall = frame(1)/(frame(1) + frame(3));
        
        precisions = [precisions precision];
        recalls = [recalls recall];
    end
    
    [recalls sortedIndexes] = sort(recalls);
    precisions = precisions(sortedIndexes);
    plot(recalls, precisions);
    xlabel('Recall'); ylabel('Precision');
    
end