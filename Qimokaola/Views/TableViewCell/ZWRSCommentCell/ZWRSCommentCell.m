//
//  ZWRSCommentCell.m
//  Qimokaola
//
//  Created by Administrator on 2016/9/29.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWRSCommentCell.h"
#import "ZWHUDTool.h"

#import "UMComResouceDefines.h"

@interface ZWRSCommentCell ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *schoolLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation ZWRSCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
        [self zw_addSubViews];
    }
    return self;
}

- (void)zw_addSubViews {
    // 内容字体大小
    CGFloat contentLabelFontSize = 16;
    // 中等文字字体大小
    CGFloat midFontSize = 14;
    // 较小文本的字体大小
    CGFloat smallFontSize = 12;
    CGFloat margin = 10.f;
    CGFloat smallMargin = 5.0f;
    CGFloat avatarHeightOrWidth = 35;
    CGFloat singleLineLabelMaxWidth = 200.f;
    
    _avatarView = [[UIImageView alloc] init];
    _avatarView.layer.cornerRadius = avatarHeightOrWidth / 2;
    _avatarView.layer.masksToBounds = YES;
    _avatarView.userInteractionEnabled = YES;
    [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToUser)]];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:midFontSize];
    _nameLabel.numberOfLines = 1;
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:smallFontSize];
    _timeLabel.numberOfLines = 1;
    _timeLabel.textColor = [UIColor lightGrayColor];
    
    _schoolLabel = [[UILabel alloc] init];
    _schoolLabel.font = [UIFont systemFontOfSize:smallFontSize];
    _schoolLabel.textColor = [UIColor lightGrayColor];
    _schoolLabel.numberOfLines = 1;
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.font = [UIFont systemFontOfSize:contentLabelFontSize];
    
    _replyLabel = [[ZWReplytPaddingLabel alloc] init];
    [_replyLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickReplyLabel)]];
    
    _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_commentButton setImage:[UIImage imageNamed:@"icon_comment"] forState:UIControlStateNormal];
    [_commentButton addTarget:self action:@selector(clickCommentButton) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *subViews = @[_avatarView, _nameLabel, _timeLabel, _schoolLabel, _contentLabel, _commentButton, _replyLabel];
    [self.contentView sd_addSubviews:subViews];
    
    UIView *contentView = self.contentView;
    
    _avatarView.sd_layout
    .leftSpaceToView(contentView, margin)
    .topSpaceToView(contentView, margin)
    .heightIs(avatarHeightOrWidth)
    .widthIs(avatarHeightOrWidth);
    
    _nameLabel.sd_layout
    .leftSpaceToView(_avatarView, margin)
    .topEqualToView(_avatarView)
    .heightIs(18);
    [_nameLabel setSingleLineAutoResizeWithMaxWidth:singleLineLabelMaxWidth];
    
    _timeLabel.sd_layout
    .leftEqualToView(_nameLabel)
    .bottomEqualToView(_avatarView)
    .heightIs(15);
    [_timeLabel setSingleLineAutoResizeWithMaxWidth:singleLineLabelMaxWidth];
    
    _schoolLabel.sd_layout
    .leftSpaceToView(_timeLabel, smallMargin)
    .topEqualToView(_timeLabel)
    .heightIs(15);
    [_schoolLabel setSingleLineAutoResizeWithMaxWidth:singleLineLabelMaxWidth];
    
    _contentLabel.sd_layout
    .leftEqualToView(_nameLabel)
    .rightSpaceToView(contentView, margin)
    .topSpaceToView(_avatarView, margin)
    .autoHeightRatio(0);
    
    _replyLabel.sd_layout
    .leftEqualToView(_contentLabel)
    .rightEqualToView(_contentLabel)
    .topSpaceToView(_contentLabel, margin);
    
    _commentButton.sd_layout
    .topSpaceToView(contentView, margin)
    .rightSpaceToView(contentView, margin)
    .heightIs(25)
    .widthEqualToHeight();
    
    [self setupAutoHeightWithBottomView:_replyLabel bottomMargin:margin];
}

- (void)setComment:(UMComComment *)comment {
    _comment = comment;
    // 自定义字段 0为不匿名 1为匿名
    if (DecodeAnonyousCode(_comment.custom)) {
        [_avatarView setImageWithURL:[NSURL URLWithString:_comment.creator.icon_url.small_url_string] placeholder:[UIImage imageNamed:@"avatar"]];
        _nameLabel.text = _comment.creator.name;
    } else {
        _avatarView.image = _comment.creator.gender.intValue == 0 ? [UIImage imageNamed:@"icon_anonymous_female"] : [UIImage imageNamed:@"icon_anonymous_male"];
        _nameLabel.text = kStudentCircleAnonyousName;
    }
    
    _schoolLabel.text = createSchoolName(_comment.creator.custom);
    _timeLabel.text = createTimeString(_comment.create_time);
    _contentLabel.text = _comment.content;
    
    if (_comment.feed) {
        _replyLabel.replyFeed = _comment.feed;
    } else if (_comment.reply_comment) {
        _replyLabel.replyComment = _comment.reply_comment;
    }
}

- (void)clickCommentButton {
    if (_comment.feed.status.intValue >= 2) {
        [ZWHUDTool showHUDWithTitle:@"该动态已被删除，试试别的吧" message:nil duration:kShowHUDShort];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didClickCommentButton:)]) {
        [self.delegate cell:self didClickCommentButton:_comment];
    }
}

- (void)clickToUser {
    if (!DecodeAnonyousCode(_comment.custom)) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didClickToUser:)]) {
        [self.delegate cell:self didClickToUser:_comment.creator];
    }
}

- (void)clickReplyLabel {
    if (_comment.feed.status.intValue >= 2) {
        [ZWHUDTool showHUDWithTitle:@"该动态已被删除，试试别的吧" message:nil duration:kShowHUDShort];
        return;
    }
    if (_comment.feed) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didClickReplyFeed:)]) {
            [self.delegate cell:self didClickReplyFeed:_comment.feed];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didClickReplyComment:)]) {
            [self.delegate cell:self didClickReplyComment:_comment.reply_comment];
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
