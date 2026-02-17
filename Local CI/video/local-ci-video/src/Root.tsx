import {Composition} from 'remotion';
import {Video} from './Video';

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="Video"
        component={Video}
        durationInFrames={1656} // 55.2 seconds at 30fps - added 5s breathing room from scene 2 onwards
        fps={30}
        width={1920}
        height={1080}
        defaultProps={{}}
      />
    </>
  );
};
