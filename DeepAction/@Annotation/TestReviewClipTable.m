


clipTable = project.ClipTable;

revClipT = ReviewClipTable(clipTable);

labels = revClipT.GetBehaviors()

%%
clipT = revClipT.GetClipTable()
clipT = revClipT.GetClipTable('complete')
clipT = revClipT.GetClipTable('incomplete')

%%
revClipT = revClipT.SetCurrentClip(1)
currClipT = revClipT.GetCurrentClipTable()
currAnnot = revClipT.GetCurrentAnnotation()

%%
revClipT = revClipT.SetCurrentClip(7)
clipT = revClipT.GetClipTable('complete')
revClipT = revClipT.MarkComplete();
clipT = revClipT.GetClipTable('complete')

%%
revClipT = revClipT.SetCurrentClip(7)
clipT = revClipT.GetClipTable('incomplete')
revClipT = revClipT.MarkIncomplete();
clipT = revClipT.GetClipTable('incomplete')

%%
revClipT = ReviewClipTable(clipTable);
labels = revClipT.GetBehaviors()
revClipT = revClipT.RenameBehavior('oldbehav', 'newbehav') % oldbehav doesn't exist
labels = revClipT.GetBehaviors()
revClipT = revClipT.RenameBehavior('oldbehav', 'newbehav') % newbehav already exists
labels = revClipT.GetBehaviors()
revClipT = revClipT.RenameBehavior('eat', 'eat2') % normal