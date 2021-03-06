//
//  ZWCommentCell.m
//  Qimokaola
//
//  Created by Administrator on 2016/9/24.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWCommentCell.h"
#import "ZWReplytPaddingLabel.h"

#import "UMComResouceDefines.h"

#import <SDAutoLayout/SDAutoLayout.h>
#import <YYKit/YYKit.h>

@interface ZWCommentCell ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *schoolLabel;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) ZWReplytPaddingLabel *replyLabel;

@end

@implementation ZWCommentCell

#pragma mark - Life Cycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
        [self zw_addSubViews];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - Common Methods

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
    _replyLabel.paddingLabelType = ZWReplyPaddingLabelTypeComment;
    
    _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_moreButton setImage:[UIImage imageNamed:@"icon_more_operation_menu"] forState:UIControlStateNormal];
    [_moreButton addTarget:self action:@selector(clickMoreButton) forControlEvents:UIControlEventTouchUpInside];
    
    _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_commentButton setImage:[UIImage imageNamed:@"icon_comment"] forState:UIControlStateNormal];
    [_commentButton addTarget:self action:@selector(clickCommentButton) forControlEvents:UIControlEventTouchUpInside];

    NSArray *subViews = @[_avatarView, _nameLabel, _timeLabel, _schoolLabel, _contentLabel, _commentButton, _moreButton, _replyLabel];
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
    
    _moreButton.sd_layout
    .topSpaceToView(contentView, margin)
    .rightSpaceToView(contentView, margin)
    .heightIs(25)
    .widthEqualToHeight();
    
    _commentButton.sd_layout
    .topEqualToView(_moreButton)
    .rightSpaceToView(_moreButton, margin)
    .heightIs(25)
    .widthEqualToHeight();
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
    
    _replyLabel.optionalReplyComment = _comment.reply_comment;
    
    UIView *bottomView = nil;
    if (_comment.reply_comment) {
        bottomView = _replyLabel;
    } else {
        bottomView = _contentLabel;
    }
    [self setupAutoHeightWithBottomView:bottomView bottomMargin:10.f];
}

- (void)clickToUser {
    if (!DecodeAnonyousCode(_comment.custom)) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didClickUser:)]) {
        [self.delegate cell:self didClickUser:_comment.creator];
    }
}

- (void)clickMoreButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickMoreButtonInInCell:)]) {
        [self.delegate didClickMoreButtonInInCell:self];
    }
}

- (void)clickCommentButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCommentButtonInCell:)]) {
        [self.delegate didClickCommentButtonInCell:self];
    }
}

@end
